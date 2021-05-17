# frozen_string_literal: true

require_relative "../../config/environment"

Benchmark.ips do |x|
  x.report("basic refresh") do
    ActiveRecord::Base.connection.execute('REFRESH MATERIALIZED VIEW links')
  end

  x.report("concurrent refresh") do
    ActiveRecord::Base.connection.execute('REFRESH MATERIALIZED VIEW CONCURRENTLY links') 
  end

  x.compare!
end
