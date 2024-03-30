#!/bin/sh
# builds our javascript

target="firefox78,chrome92,edge92,safari14"
outdir="app/assets/builds"
jsdir="app/javascript"
options="--bundle --minify --sourcemap --target=$target --outdir=$outdir"

entrypoints="$jsdir/cmp.js $jsdir/oligrapher_chart.js $jsdir/sankey_chart.js $jsdir/swamped.js $jsdir/actiontext.js $jsdir/oligrapher_lock.js"
applicationjs="$jsdir/application.js"

# build entrypoints
printf "\033[93mBundling entrypoints\033[0m\n"
echo esbuild $entrypoints $options
npx  esbuild $entrypoints $options

# application.js uses jquery plugins that require the use of inject
options="$options --inject:$jsdir/src/common/inject-jquery.js"

# using --watch for auto-rebuilding. note that this only works for
# application.js and not the above entry points
if [ "$1" = "--watch" ]; then
    options="$options --watch"
fi

# build application.js
printf "\033[93mBundling application.js\033[0m\n"
echo esbuild $applicationjs $options
npx  esbuild $applicationjs $options
