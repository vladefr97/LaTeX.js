#!/usr/local/bin/lsc -cj

name: 'latex.js'
description: 'JavaScript LaTeX to HTML5 translator'
version: '0.12.1'

author:
    'name': 'Michael Brade'
    'email': 'brade@kde.org'

keywords:
    'pegjs'
    'latex'
    'parser'
    'html5'

bin:
    'latex.js': './bin/latex.js'

main:
    'dist/latex.esm.js'

browser:
    'dist/latex.js'

files:
    'bin/latex.js'
    'dist/latex.js'
    'dist/latex.js.map'
    'dist/latex.esm.js'
    'dist/latex.esm.js.map'
    'dist/latex.component.js'
    'dist/latex.component.js.map'
    'dist/latex.component.esm.js'
    'dist/latex.component.esm.js.map'
    'dist/css/'
    'dist/fonts/'
    'dist/js/'

scripts:
    clean: 'rimraf dist bin test/coverage docs/js/playground.bundle.*;'
    build: 'NODE_ENV=production npm run devbuild;'
    devbuild: "
        rimraf 'dist/**/*.js.map';
        mkdirp dist/css;
        mkdirp dist/js;
        mkdirp dist/fonts;
        rsync -a src/css/ dist/css/;
        rsync -a src/fonts/ dist/fonts/;
        rsync -a node_modules/katex/dist/fonts/*.woff dist/fonts/;
        rsync -a src/js/ dist/js/;
        mkdirp bin;
        lsc -bc --no-header -m embedded -p src/cli.ls > bin/latex.js;
        chmod a+x bin/latex.js;
	    rollup -c --environment GOAL:library-esm &
	    rollup -c --environment GOAL:library-umd &
	    rollup -c --environment GOAL:webcomponent-esm &
	    rollup -c --environment GOAL:webcomponent-umd &
	    rollup -c --environment GOAL:playground;
        wait;
    "

    test:  'mocha test/*.ls;'
    iron:  'iron-node node_modules/.bin/_mocha test/*.ls;'

    testc: "
        nyc --include='bin' --include='src' --include='dist' -e '.ls' \
            ./node_modules/.bin/mocha -i -g screenshot --reporter mocha-junit-reporter --reporter-options mochaFile=./test/test-results.xml test/*.ls
        &&
        mocha -g screenshot --reporter mocha-junit-reporter --reporter-options mochaFile=./test/screenshots/test-results.xml test/*.ls;
    "
    cover: 'nyc report --reporter=html --reporter=text --reporter=lcovonly --report-dir=test/coverage && codecov;'

dependencies:
    ### CLI dependencies

    'commander': '2.20.x'
    'fs-extra': '8.x'
    'js-beautify': '1.10.x'
    'stdin': '*'

    'hyphenation.en-us': '*'
    'hyphenation.de': '*'

    'svgdom': 'https://github.com/michael-brade/svgdom'
    #'cheerio': '0.x'
    #'xmldom': '^0.1.19'

devDependencies:
    ### actual runtime dependencies, but bundled by rollup

    'he': '1.2.x'
    'katex': '0.10.0'
    '@svgdotjs/svg.js': '3.x',

    'hypher': '0.x'
    'lodash': '4.x'

    'livescript': 'https://github.com/michael-brade/LiveScript'

    ### building

    'pegjs': '0.10.x'
    'mkdirp': '0.5.x'
    'rimraf': '2.6.x'
    'tmp': '0.x'
    'glob': '^7.1.4'

    ### bundling

    "rollup": "^1.15.5"
    "rollup-plugin-extensions": "^0.1.0"
    "rollup-plugin-pegjs": "^2.1.3"
    "rollup-plugin-livescript": "^0.1.1"
    "rollup-plugin-commonjs": "^10.0.0"
    "rollup-plugin-node-resolve": "^5.0.2"
    "rollup-plugin-terser": "^5.0.0"
    "rollup-plugin-re": "^1.0.7"
    "rollup-plugin-copy": "^3.0.0"

    ### testing

    'mocha': '6.x'
    'mocha-junit-reporter': '1.23.x'
    'chai': '4.x'
    'chai-as-promised': '7.x'
    'slugify': '1.3.x'
    'decache': '4.5.x'

    'puppeteer': '1.19.x'
    'puppeteer-firefox': '0.x'
    'pixelmatch': '5.x'

    'nyc': '14.x'
    'codecov': '3.x'

    'serve-handler': '6.x'

repository:
    type: 'git'
    url: 'git+https://github.com/michael-brade/LaTeX.js.git'

license: 'MIT'

bugs:
    url: 'https://github.com/michael-brade/LaTeX.js/issues'

homepage: 'https://latex.js.org'

engines:
    node: '>= 8.0'
