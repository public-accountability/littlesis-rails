namespace :cache do
  desc "Clear site cache"
  task :clear => :environment do
    Rails.cache.clear
  end
end