#!/usr/bin/env node
// Compiles our javascript with esbuild to app/assets/builds
// npm run build will run this file
// add '--watch' for automatic rebuilds

// all paths are relative to app/javascript in the rails directory
const jsDirectory = "./app/javascript"

const mainEntry = "application.js"
// These are *in addition*  to application.js
const entryPoints = [
  "cmp.js",
  "oligrapher_chart.js",
  "sankey_chart.js",
  "swamped.js",
  "actiontext.js",
]

const baseConfig = {
  bundle: true,
  minify: true,
  sourcemap: true,
  target: ["firefox78", "chrome92", "edge92", "safari14"],
  outdir: "app/assets/builds",
}

if (process.argv[2] === "--watch") {
  baseConfig.watch = {
    onRebuild(error, result) {
      if (error) console.error("watch build failed:", error)
      else console.log("watch build succeeded:", result)
    },
  }
}

const path = require("path")
const esbuild = require("esbuild")

function build(config) {
  return esbuild
    .build(Object.assign({}, baseConfig, config))
    .then(console.log)
    .catch(error => {
      console.error(error)
      process.exit(1)
    })
}

// build application.js
// Uses inject to include jQuery, necessary for some of our javascript
// "$" can be used to refer to jquery anwhere without having to import it
build({
  inject: [path.join(jsDirectory, "src/common/inject-jquery.js")],
  entryPoints: [path.join(jsDirectory, mainEntry)],
})

// Creates rest of end points
build({ entryPoints: entryPoints.map(f => path.join(jsDirectory, f)) })
