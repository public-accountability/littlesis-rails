Rails.application.config.assets.precompile += [
  'nys.js',
  'oligrapher.js',
  'oligrapher-dev.js',
  'oligrapher-dev.js.map',
  'toolkit.js',
  'toolkit.scss',
  'splash.scss',
  'extension.js',
  'markdown_editor.js',
  'markdown_editor.scss',
  'relationships_datatable.js'
]

Rails.application.config.assets.precompile += %w(*.png *.jpg *.jpeg *.gif *.svg *.eot *.woff *.woff2 *.ttf)

Rails.application.config.assets.digest = true
Rails.application.config.assets.version = '1.0'

# Add Yarn node_modules folder to the asset load path.
# Rails.application.config.assets.paths << Rails.root.join('node_modules')

