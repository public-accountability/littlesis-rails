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

  desc "fixes bucket name in amazon image urls"
  task fix_image_urls: :environment do
    bucket_name = Lilsis::Application.config.aws_s3_bucket

    NetworkMap.all.each do |map|
      hash = JSON.parse(map.data)

      entities = hash['entities'].map do |entity|
        if entity['image'].present?
          image = entity['image']

          entity['image'].gsub!(/(s3\.amazonaws\.com\/)[^\/]+/i, '\1' + bucket_name) 
          entity['image'].gsub!(/\/\/[^\.]+(\.s3\.amazonaws\.com)/i, bucket_name + '\1')

          print "replaced #{image} with #{entity['image']}\n" unless image == entity['image']
        end

        entity
      end

      json = JSON.dump({
        entities: entities,
        rels: hash['rels'],
        texts: hash['texts'].present? ? hash['texts'] : []
      })

      map.data = ERB::Util.json_escape(json)
      map.save
    end

    print "fixed map image urls\n"
  end

  desc "remove default images"
  task remove_default_images: :environment do
    NetworkMap.all.each do |map|
      print "cleaning #{map.name} (#{map.id})...\n"

      hash = JSON.parse(map.data)

      entities = hash['entities'].map do |entity|
        if entity['image'].present? and (entity['image'].match(/netmap-(org|person)/) or entity['image'].match(/anon(s)\.png/))
          entity['image'] = nil
          print "removed default image from #{entity['name']}\n"
        end

        entity
      end

      json = JSON.dump({
        entities: entities,
        rels: hash['rels'],
        texts: hash['texts'].present? ? hash['texts'] : []
      })

      map.data = ERB::Util.json_escape(json)
      map.title = map.name if map.title.blank?
      map.save!
    end

    print "fixed map image urls\n"
  end  
end