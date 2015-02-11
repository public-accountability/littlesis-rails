namespace :entities do
  desc "get missing company SEC CIKs using tickers"
  task create_fields_from_legacy_keys: :environment do |task|
    Entity.all.each do |entity|
      entity.update_fields_from_extensions
    end

    Entiy.joins(:external_keys).each do |entity|
      entity.update_fields_from_external_keys
    end
  end
end