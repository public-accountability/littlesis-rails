ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../Gemfile', __dir__)

require 'bundler/setup' # Set up gems listed in the Gemfile.

# Generally all you have to do is:
#   require 'bootsnap/setup'
# to setup bootsnap.
# However, there is a bug relates to loading yaml from file objects
# that affects us: https://github.com/Shopify/bootsnap/issues/124
# Until that's resolved, caching yaml is disabled.
require 'bootsnap'
env = ENV['RAILS_ENV'] || 'development'
Bootsnap.setup(
  cache_dir:            'tmp/cache',          # Path to your cache
  development_mode:     env == 'development', # Current working environment, e.g. RACK_ENV, RAILS_ENV, etc
  load_path_cache:      true,                 # Optimize the LOAD_PATH with a cache
  autoload_paths_cache: true,                 # Optimize ActiveSupport autoloads with cache
  disable_trace:        false,                # (Alpha) Set `RubyVM::InstructionSequence.compile_option = { trace_instruction: false }`
  compile_cache_iseq:   true,                 # Compile Ruby code into ISeq cache, breaks coverage reporting.
  compile_cache_yaml:   true                  # Compile YAML into a cache
)
