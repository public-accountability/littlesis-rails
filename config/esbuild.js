#!/usr/bin/env node
// Runs esbuild to compile javascript in app/assets/builds
// Almost equivalent running this on the command line:
//  esbuild app/javascript/*.* --bundle --minify --target=firefox78,chrome92,edge92,safari13 --outdir=app/assets/builds --inject:app/javascript/src/common/inject-jquery.js
// add '--watch' for automatical rebuilds: littlesis yarn build -- --watch

const path = require('path')
const esbuild = require('esbuild')

// These are *in addition*  to application.js
const entryPoints = ["cmp.js", "oligrapher_chart.js", "swamped.js", "actiontext.js"]

const jsDirectory = './app/javascript'

const baseConfig = {
  bundle: true,
  minify: true,
  target: ['firefox78', 'chrome92', 'edge92', 'safari13'],
  outdir: 'app/assets/builds',
}

if (process.argv[2] === '--watch') {
  baseConfig.watch = {
    onRebuild(error, result) {
      if (error) console.error('watch build failed:', error)
      else console.log('watch build succeeded:', result)
    }
  }
}

function build(config) {
  return esbuild
    .build(Object.assign({}, baseConfig, config))
    .then(console.log)
    .catch(() => process.exit(1))
}

// build application.js
// uses inject to include jQuery which is not inlucded by default in other files
build({ inject: [path.join(jsDirectory, 'src/common/inject-jquery.js')], entryPoints: [path.join(jsDirectory, 'application.js')] })

// builds rest of entrypints
build({ entryPoints: entryPoints.map(f => path.join(jsDirectory, f)) })
