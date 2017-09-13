require Rails.root.join('lib', 'task-helpers', 'bulk_tagger.rb')

namespace :tags do
  desc 'bulk tag a csv of entities'
  task :entity, [:file] => :environment do |t, args|
    BulkTagger.new(args[:file], :entity).run
  end
end
