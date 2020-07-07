# frozen_string_literal: true

namespace :maps do
  desc "generates thumbnails for recently saved public maps"
  task :generate_recent_thumbs_by_amount, [:amount] => :environment do |_t, args|
    amount = args[:amount].nil? ? 50 : args[:amount]

    NetworkMap.public_scope.order('updated_at desc').limit(amount).each do |map|
      map.generate_thumbnail
      sleep(1)
    end
  end

  desc "generates thumbnails for maps updated in the past X hours"
  task :generate_recent_thumbs, [:hours] => :environment do |_t, args|
    num_hours = args[:hours].nil? ? 25 : args[:hours].to_i

    NetworkMap.public_scope.where("updated_at >= ?", num_hours.hours.ago).each do |map|
      map.generate_thumbnail
      sleep(1)
    end
  end

  desc "generates thumbnails for all public maps"
  task generate_all_thumbs: :environment do
    NetworkMap.public_scope.each do |map|
      map.generate_thumbnail
      sleep(1)
    end
  end

  desc "generates thumbnails for maps that are missing images"
  task generate_missing_thumbs: :environment do
    NetworkMap.public_scope.where(thumbnail: nil).each do |map|
      map.generate_thumbnail
      sleep(1)
    end
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
end
