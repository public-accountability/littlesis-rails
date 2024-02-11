namespace :sitemap do
  desc "generates sitemap files"
  task :run => :environment do
    require 'sitemap'
    Sitemap.run
  end
end
