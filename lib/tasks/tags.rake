require Rails.root.join('lib', 'task-helpers', 'bulk_tagger.rb')
require "benchmark"

namespace :tags do
  desc 'bulk tag a csv of entities'
  task :entity, [:file] => :environment do |t, args|
    BulkTagger.new(args[:file], :entity).run
  end

  desc 'bulk tag a csv of lists'
  task :list, [:file] => :environment do |t, args|
    BulkTagger.new(args[:file], :list).run
  end

  desc 'benchmark entities_by_relationship_count'
  task bm_count: :environment do
    times = 5
    tag = Tag.find(3)

    puts "args: 'Person'"
    puts '------------------------'

    old_avg_time = Array.new(times) do
      Benchmark.measure { tag.send(:entities_by_relationship_count_old, 'Person') }.real
    end.sum / times.to_f

    new_avg_time = Array.new(times) do
      Benchmark.measure { tag.send(:entities_by_relationship_count, 'Person') }.real
    end.sum / times.to_f

    puts "Old time elapsed: #{old_avg_time}"
    puts "New time elapsed: #{new_avg_time}"
    puts "Difference: #{new_avg_time - old_avg_time}"
    puts '------------------------'
    puts "args: 'Org', 2"
    puts '------------------------'

    old_avg_time = Array.new(times) do
      Benchmark.measure { tag.send(:entities_by_relationship_count_old, 'Org', 2) }.real
    end.sum / times.to_f

    new_avg_time = Array.new(times) do
      Benchmark.measure { tag.send(:entities_by_relationship_count, 'Org', 2) }.real
    end.sum / times.to_f

    puts "Old time elapsed: #{old_avg_time}"
    puts "New time elapsed: #{new_avg_time}"
    puts "Difference: #{new_avg_time - old_avg_time}"
    puts '------------------------'

    puts '------------------------'
    puts "args: 'Org', 3"
    puts '------------------------'

    old_avg_time = Array.new(times) do
      Benchmark.measure { tag.send(:entities_by_relationship_count_old, 'Org', 3) }.real
    end.sum / times.to_f

    new_avg_time = Array.new(times) do
      Benchmark.measure { tag.send(:entities_by_relationship_count, 'Org', 3) }.real
    end.sum / times.to_f

    puts "Old time elapsed: #{old_avg_time}"
    puts "New time elapsed: #{new_avg_time}"
    puts "Difference: #{new_avg_time - old_avg_time}"
    puts '------------------------'
  end
end
