# frozen_string_literal: true

# Creates two public data JSON files
#   - data/public_data/entities.json
#   - data/public_data/relationships.json
module PublicData
  DIR = Rails.root.join('data/public_data')

  def self.run
    FileUtils.mkdir_p DIR
    save_json(Entity)
    save_json(Relationship)
  end

  def self.save_json(klass)
    File.open(DIR.join("#{klass.name.pluralize.downcase}.json"), 'w') do |f|
      f.write '['

      klass.find_each do |model|
        f.write model.api_data.to_json
        f.write ','
      rescue => err
        Rails.logger.warn "Failed to get api_data for #{klass.name} #{model.id}"
        Rails.logger.warn err.message
      end

      f.seek(-1, IO::SEEK_CUR)
      f.write ']'
    end
  end

  def self.gzip
    system "gzip --keep #{DIR.join('entities.json')}"
    system "gzip --keep #{DIR.join('relationships.json')}"
  end
end
