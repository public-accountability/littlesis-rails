# frozen_string_literal: true

namespace :maps do
  desc "generates thumbnails for recently saved public maps and saves them to S3"
  task :generate_recent_thumbs_by_amount, [:amount] =>  :environment do |_t, args|
    amount = args[:amount].nil? ? 50 : args[:amount]

    NetworkMap.public_scope.order('updated_at desc').limit(amount).each do |map|
      map.generate_s3_thumb
      puts "saved thumbnail for map #{map.id} '#{map.name}': #{map.thumbnail}"
      sleep(1)
    end
  end

  desc "generates thumbnails for maps updated in the past X hours and saves them to S3"
  task :generate_recent_thumbs, [:hours] => :environment do |_t, args|
    num_hours = args[:hours].nil? ? 25 : args[:hours].to_i

    NetworkMap.public_scope.where("updated_at >= ?", num_hours.hours.ago).each do |map|
      map.generate_s3_thumb
      puts "saved thumbnail for map #{map.id} '#{map.name}': #{map.thumbnail}"
      sleep(1)
    end
  end

  desc "generates thumbnails for all public maps and saves them to S3"
  task generate_all_thumbs: :environment do
    NetworkMap.public_scope.each do |map|
      map.generate_s3_thumb
      puts "saved thumbnail for map #{map.id} '#{map.name}': #{map.thumbnail}"
      sleep(1)
    end
  end

  desc "generates thumbnails for maps that are missing images and saves them to S3"
  task generate_missing_thumbs: :environment do
    NetworkMap.public_scope.where(thumbnail: nil).each do |map|
      map.generate_s3_thumb
      puts "saved thumbnail for map #{map.id} '#{map.name}': #{map.thumbnail}"
      sleep(1)
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

  desc 'populate all entity map collections'
  task update_all_entity_map_collections: :environment do
    Rails.cache.delete_matched EntityNetworkMapCollection::MATCH_PATTERN

    NetworkMap.find_each(batch_size: 250) do |network_map|
      unless network_map.title == 'Untitled Map'
        network_map.entities.pluck(:id).each do |entity_id|
          EntityNetworkMapCollection
            .new(entity_id)
            .add(network_map.id)
            .save
        end
      end
    end
  end

  desc 'Update broken or missing images for a given map'
  task :refresh_images, [:map_id] =>  :environment do |_t, args|
    NetworkMap.find(args[:map_id]).refresh_images
  end
end
