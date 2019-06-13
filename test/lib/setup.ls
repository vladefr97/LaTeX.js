require! {
    fs
    chai
    puppeteer: puppeteerCh
    'puppeteer-firefox': puppeteerFF
    pixelmatch
    pngjs: { PNG }
}

chai.use require 'chai-as-promised'

global.expect = chai.expect
global.test = it                # because livescript sees "it" as reserved variable

global.pageCh = undefined         # used to make screenshots
global.pageFF = undefined


var browserCh, browserFF

before !->>
    browserCh := await puppeteerCh.launch {
        devtools: false
        dumpio: false
        args: ['--no-sandbox', '--disable-setuid-sandbox']
        defaultViewport: { width: 1000, height: 0, deviceScaleFactor: 2 }
    }

    browserFF := await puppeteerFF.launch!

    global.pageCh = (await browserCh.pages!).0              # there is always one page available
    global.pageFF = await browserFF.newPage!

    # console.log pageFF

    pageCh.on 'console', (msg) ->
        if msg._type == 'error'
            console.error msg._text

    pageFF.on 'console', (msg) ->
        if msg._type == 'error'
            console.error msg._text


after !->>
    await browserCh.close!
    await browserFF.close!


# take screenshot of current page
global.takeScreenshot = (page, filename) !->>
    console.log("about to take it...")
    await page.screenshot {
        omitBackground: true
        path: filename + '.new.png'
    }
    console.log("done.", t)

    if fs.existsSync filename + '.png'
        # now compare the screenshots and delete the new one if they match
        png1 = PNG.sync.read(fs.readFileSync(filename + '.png'))
        png2 = PNG.sync.read(fs.readFileSync(filename + '.new.png'))

        diff = new PNG { width: png1.width, height: png1.height }

        dfpx = pixelmatch png1.data, png2.data, diff.data, png1.width, png1.height, threshold: 0

        diff.pack!.pipe(fs.createWriteStream(filename + '.diff.png'))

        if dfpx > 0
            throw new Error "screenshots differ by #{dfpx} pixels - see #{filename + '.*.png'}"
        else
            fs.unlinkSync filename + '.new.png'
            fs.unlinkSync filename + '.diff.png'
    else
        # if no screenshot exists yet, use this new one
        fs.renameSync filename + '.new.png', filename + '.png'
