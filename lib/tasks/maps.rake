# frozen_string_literal: true

namespace :maps do
  namespace :screenshot do
    desc 'create screenshots for all maps missing thumbnails'
    task :missing, [:force] => :environment do |_t, args|
      args.with_defaults(force: false)
      NetworkMap.where(is_private: false).order(updated_at: :desc).find_each(batch_size: 100) do |map|
        if args[:force] || !map.screenshot_exists?
          map.take_screenshot
        end
      end
    end

    desc 're-take screenshots for all featured thumbnails'
    task featured: :environment do
      NetworkMap.featured.each do |map|
        ColorPrinter.print_blue "Taking Screenshot for #{map.to_param}"
        map.take_screenshot
      end
    end

    desc 'create screenshots for maps updated in the past X hours'
    task :recent, [:hours] => :environment do |_t, args|
      args.with_defaults(hours: 25)
      NetworkMap.where('updated_at > ?', hours.to_i.hours.ago).each(&:take_screenshot)
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
