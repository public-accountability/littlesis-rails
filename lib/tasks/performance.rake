require 'benchmark'

namespace :performance do
  
  desc 'User.active_users performance'
  task active_users: :environment do

    benchmark = Benchmark.measure do
      User.active_users(since: 3.months.ago, page: 1)
      User.active_users(since: 3.months.ago, page: 2)
      User.active_users(since: 3.months.ago, page: 3)
    end

    puts benchmark
    puts "real time: #{benchmark.real}"
    
  end

end
