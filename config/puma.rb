# Specifies the `environment` that Puma will run in.
#
rails_env = ENV.fetch("RAILS_ENV") { "development" }

environment rails_env

# Puma can serve each request in a thread from an internal thread pool.
# The `threads` method setting takes two numbers: a minimum and maximum.
# Any libraries that use thread pools should be configured to match
# the maximum value specified for Puma. Default is set to 5 threads for minimum
# and maximum; this matches the default thread size of Active Record.
#
# threads_count = ENV.fetch("RAILS_MAX_THREADS") { 5 }
threads_count = 5
threads threads_count, threads_count

if rails_env == 'production'
  bind ENV.fetch('LITTLESIS_SOCKET') { "unix:///run/littlesis.sock" }
  pidfile ENV.fetch('LITTLESIS_PIDFILE') { '/var/www/littlesis/tmp/puma.pid' }
  state_path ENV.fetch('LITTLESIS_PUMA_STATE') { '/var/www/littlesis/tmp/puma.state' }
else
  # Defaults to 8080 on 127.0.0.1 in development. To serve on all interfaces set
  # the environment variable LITTLESIS_BIND to "tcp://0.0.0.0:8080"
  bind ENV.fetch('LITTLESIS_BIND') { "tcp://127.0.0.1:8080" }
  pidfile ENV.fetch('LITTLESIS_PIDFILE') { 'tmp/puma.pid' }
end

# Specifies the number of `workers` to boot in clustered mode.
# Workers are forked webserver processes. If using threads and workers together
# the concurrency of the application would be max `threads` * `workers`.
# Workers do not work on JRuby or Windows (both of which do not support
# processes).
#
workers ENV.fetch("WEB_CONCURRENCY") { 2 }

# Use the `preload_app!` method when specifying a `workers` number.
# This directive tells Puma to first boot the application and load code
# before forking the application. This takes advantage of Copy On Write
# process behavior so workers use less memory. If you use this option
# you need to make sure to reconnect any threads in the `on_worker_boot`
# block.
#
# preload_app!

# If you are preloading your application and using Active Record, it's
# recommended that you close any connections to the database before workers
# are forked to prevent connection leakage.
#
# before_fork do
#  ActiveRecord::Base.connection_pool.disconnect!
# end

# the code in the `on_worker_boot` will be called if you are using
# clustered mode by specifying a number of `workers`. After each worker
# process is booted, this block will be run. If you are using the `preload_app!`
# option, you will want to use this block to reconnect to any threads
# or connections that may have been created at application boot, as Ruby
# cannot share connections between processes.
#
# on_worker_boot do
#   ActiveRecord::Base.establish_connection
# end

# Allow puma to be restarted by `rails restart` command.
plugin :tmp_restart
