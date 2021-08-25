# frozen_string_literal: true

# Combined Importer and Processor for NYCC council members
# The data is conveniently stored as JSON on github.
# The dataset is "PersonId", which is not documented from the data source,
# but it appears to be a unique identifier for each council member.

module NYCCImporter
  SOURCE_URL = 'https://raw.githubusercontent.com/NewYorkCityCouncil/districts/master/district_data/council_members/members.json'
  DATA_FILE = Rails.root.join('data/nyc_council_members.json')

  def self.run
    download_data
    import
    process
  end

  def self.import
    JSON.parse(File.read(DATA_FILE)).each do |member|
      ExternalData
        .nycc
        .find_or_initialize_by(dataset_id: member.fetch('PersonId'))
        .merge_data(member)
        .save!
    end
  end

  def self.process
    ExternalData.nycc.each do |external_data|
      ExternalEntity
        .nycc
        .find_or_create_by!(external_data: external_data)
    end
  end

  def self.download_data
    unless DATA_FILE.exist?
      File.write DATA_FILE, Net::HTTP.get(URI(SOURCE_URL))
    end
  end
end
