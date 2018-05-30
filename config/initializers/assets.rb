Rails.application.config.assets.precompile += %w( nys.js oligrapher.js oligrapher-dev.js toolkit.js toolkit.scss splash.scss extension.js markdown_editor.js markdown_editor.scss )
Rails.application.config.assets.precompile += %w(*.png *.jpg *.jpeg *.gif *.svg *.eot *.woff *.ttf)

Rails.application.config.assets.digest = true
Rails.application.config.assets.version = '1.0'

# Add Yarn node_modules folder to the asset load path.
# Rails.application.config.assets.paths << Rails.root.join('node_modules')

