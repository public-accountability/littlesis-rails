# frozen_string_literal: true

# Rails.application.config.assets.version = '1.0'

# Add Yarn node_modules folder to the asset load path.
Rails.application.config.assets.paths << Rails.root.join('node_modules')
