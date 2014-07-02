namespace :maps do
  desc "generates thumbnails for recently saved public maps and saves them to S3"
  task generate_recent_thumbs: :environment do
    hostname = ENV['RAILS_ENV'] == 'production' ? 'http://littlesis.org' : 'http://lilsis.local'
    Rails.application.routes.default_url_options[:host] = hostname
    s3 = S3.s3

    NetworkMap.public_scope.where("updated_at > '#{24.hours.ago.to_s}'").each do |map|
      map.generate_s3_thumb(s3)
      print "saved thumbnail for map #{map.id} '#{map.name}': #{map.thumbnail}\n"
    end
  end

  desc "generates thumbnails for all public maps and saves them to S3"
  task generate_all_thumbs: :environment do
    hostname = ENV['RAILS_ENV'] == 'production' ? 'http://littlesis.org' : 'http://lilsis.local'
    Rails.application.routes.default_url_options[:host] = hostname
    s3 = S3.s3

    NetworkMap.public_scope.each do |map|
      map.generate_s3_thumb(s3)
      print "saved thumbnail for map #{map.id} '#{map.name}': #{map.thumbnail}\n"
    end
  end
end