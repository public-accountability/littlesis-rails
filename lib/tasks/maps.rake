namespace :maps do
  desc "generates thumbnails for recently saved public maps and saves them to S3"
  task :generate_recent_thumbs_by_amount, [:amount] =>  :environment do |t, args|
    hostname = ENV['RAILS_ENV'] == 'production' ? 'https://littlesis.org' : 'http://ls.dev:8080'
    Rails.application.routes.default_url_options[:host] = hostname
    amount = args[:amount].nil? ? 50 : args[:amount]

    NetworkMap.public_scope.order('updated_at desc').limit(amount).each do |map|
      map.generate_s3_thumb
      puts "saved thumbnail for map #{map.id} '#{map.name}': #{map.thumbnail}"
    end
  end

  desc "generates thumbnails for maps updated in the past X hours and saves them to S3"
  task :generate_recent_thumbs, [:hours] =>  :environment do |t, args|
    hostname = ENV['RAILS_ENV'] == 'production' ? 'https://littlesis.org' : 'http://ls.dev:8080'
    Rails.application.routes.default_url_options[:host] = hostname
    num_hours = args[:hours].nil? ? 25 : args[:hours].to_i

    NetworkMap.public_scope.where("updated_at >= ?", num_hours.hours.ago).each do |map|
      map.generate_s3_thumb
      puts "saved thumbnail for map #{map.id} '#{map.name}': #{map.thumbnail}"
    end
  end

  desc "generates thumbnails for all public maps and saves them to S3"
  task generate_all_thumbs: :environment do
    hostname = ENV['RAILS_ENV'] == 'production' ? 'https://littlesis.org' : 'http://ls.dev:8080'
    Rails.application.routes.default_url_options[:host] = hostname

    NetworkMap.public_scope.each do |map|
      map.generate_s3_thumb
      puts "saved thumbnail for map #{map.id} '#{map.name}': #{map.thumbnail}"
    end
  end

  desc "generates thumbnails for maps that are missing images and saves them to S3"
  task generate_missing_thumbs: :environment do
    hostname = ENV['RAILS_ENV'] == 'production' ? 'https://littlesis.org' : 'http://ls.dev:8080'
    Rails.application.routes.default_url_options[:host] = hostname

    NetworkMap.public_scope.where(thumbnail: nil).each do |map|
      map.generate_s3_thumb
      puts "saved thumbnail for map #{map.id} '#{map.name}': #{map.thumbnail}"
    end
  end

  desc "fixes bucket name in amazon image urls"
  task fix_image_urls: :environment do
    bucket_name = Lilsis::Application.config.aws_s3_bucket

    def entity_type(entity)
      return entity['type'] if entity['type']
      if entity = Entity.where(id: entity['id']).first
        return entity.primary_ext
      end
      nil
    end

    NetworkMap.all.each do |map|
      hash = JSON.parse(map.data)

      puts "fixing urls in map #{map.id}..."

      entities = hash['entities'].map do |entity|
        if entity['image'].present?
          image = entity['image'].dup

          entity['image'].gsub!(/(s3\.amazonaws\.com\/)[^\/]+/i, '\1' + bucket_name) 
          entity['image'].gsub!(/\/\/[^\.]+(\.s3\.amazonaws\.com)/i, bucket_name + '\1')
          entity['image'].gsub!(/^https?:\/\//i, "//")
          entity['image'].gsub!(/\/profile\//, "/face/") if entity_type(entity) == 'Person'

          puts "replaced #{image} with #{entity['image']}" unless image == entity['image']
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

    puts "fixed map image urls"
  end

  desc "remove default images"
  task remove_default_images: :environment do
    NetworkMap.all.each do |map|
      puts "cleaning #{map.name} (#{map.id})..."

      hash = JSON.parse(map.data)

      entities = hash['entities'].map do |entity|
        if entity['image'].present? and (entity['image'].match(/netmap-(org|person)/) or entity['image'].match(/anon(s)\.png/))
          entity['image'] = nil
          puts "removed default image from #{entity['name']}"
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

    puts "fixed map image urls"
  end

  desc "support https in image urls"
  task remove_default_images: :environment do
  end

  desc "generate secret hash for all network maps"
  task generate_secrets: :environment do
    maps = NetworkMap.where(secret: nil)
    puts "generating secret hash for #{maps.count} maps...\n"
    maps.each do |map|
      map.generate_secret
      map.save
      puts (i + 1).to_s
    end
    print "\n"
  end

  desc "convert map JSON to graph JSON"
  task generate_oligrapher_data: :environment do
    maps = NetworkMap.where(graph_data: nil)
    puts "generating oligrapher data for #{maps.count} maps...\n"
    maps.each_with_index do |map, i|
      path = Rails.root.to_s + "/tmp/mapData.json"
      open(path, "w") { |f| f << map.data }
      oligrapher_data = `node #{Rails.root}/bin/convertMap.js #{path}`
      annotations_data = JSON.dump(map.annotations.map { |a| Oligrapher.annotation_data(a) })
      map.update(graph_data: oligrapher_data)
      map.update(annotations_data: annotations_data)
      map.update(annotations_count: map.annotations.count)
      puts (i + 1).to_s
    end
    print "\n"
  end

  desc "convert legacy map descriptions into annotations"
  task descriptions_to_annotations: :environment do
    include_maps_with_annotations = ENV['INCLUDE_MAPS_WITH_ANNOTATIONS'] || false
    maps = NetworkMap.with_description
    maps = maps.without_annotations unless include_maps_with_annotations      
    puts "converting legacy map descriptions into annotations for #{maps.count} maps...\n"
    maps.each_with_index do |map, i|
      next if !include_maps_with_annotations and map.has_annotations
      next if map.annotations.map { |a| a["text"] }.include?(map.description)
      map.update(annotations_data: map.annotatons_data_with_description)
      map.update(annotations_count: map.annotations.count)
      map.update(description: nil)
      puts "[#{i+1}] processed map #{map.id}: #{map.title}"
    end
    print "\n"
  end
end
