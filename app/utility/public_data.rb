# frozen_string_literal: true

# Creates two public data JSON files
#   - data/public_data/entities.json
#   - data/public_data/relationships.json
module PublicData
  DIR = Rails.root.join('data/public_data')

  def self.run
    FileUtils.mkdir_p DIR

    File.open(DIR.join('entities.json'), 'w') do |f|
      f.write '['

      Entity.find_each do |e|
        begin
          f.write e.api_data.to_json
          f.write ','
        rescue => err
          Rails.logger.warn "Failed to get api_data for Entity #{e.name_with_id}"
          Rails.logger.warn err.message
        end
      end

      f.seek(-1, IO::SEEK_CUR)
      f.write ']'
    end

    File.open(DIR.join('relationships.json'), 'w') do |f|
      f.write '['

      Relationship.find_each do |r|
        begin
          f.write r.api_data.to_json
          f.write ','
        rescue => err
          Rails.logger.warn "Failed to get api_data for Relationship #{r.id}"
          Rails.logger.warn err.message
        end
      end

      f.seek(-1, IO::SEEK_CUR)
      f.write ']'
    end
  end

  def gzip
    system "gzip --keep #{DIR.join('entities.json')}"
    system "gzip --keep #{DIR.join('relationships.json')}"
  end
end
