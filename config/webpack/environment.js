const { environment } = require('@rails/webpacker')
const webpack = require('webpack')

environment.plugins.append('Provide', new webpack.ProvidePlugin({
  $: 'jquery',
  jQuery: 'jquery',
  api: 'packs/common/api'
}))

environment.loaders.append('babel', {
  test: /\.js?/,
  use: 'babel-loader',
  exclude: /node_modules/
})

environment.loaders.append('json', {
  test: /\.json?/,
  use: 'json-loader',
  exclude: /node_modules/,
  type: 'javascript/auto'
})

module.exports = environment
