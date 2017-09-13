require 'rails_helper'
require 'csv'
require Rails.root.join('lib', 'task-helpers', 'bulk_tagger.rb')

describe 'BulkTagging' do
  context 'Tagging entites' do
    let(:csv) do
      CSV.generate do |csv|
        csv << ['entity_url', 'tags', 'tag_all_related']
        csv << ['https://littlesis.org/org/123/org_name', 'nyc', '']
        csv << ['https://littlesis.org/org/456-org_name', 'oil', '']
        csv << ['/person/789-person_name', 'nyc oil', '']
        csv << ['http://littlesis.org/person/1000/person_name', 'georgia', '']
      end
    end

    before do
      allow(File).to receive(:open).and_return(double(:read => csv))
    end

    let(:tagger) { BulkTagger.new('tags.csv') }

    def tagable_mock(tags)
      double('tagable').tap do |double|
        tags.each { |t| expect(double).to receive(:tag).with(t) }
      end
    end

    it 'It tags entity by tag' do
      expect(Entity).to receive(:find).with('123')
                          .and_return(tagable_mock(['nyc']))
      expect(Entity).to receive(:find).with('456')
                          .and_return(tagable_mock(['oil']))
      expect(Entity).to receive(:find).with('789')
                          .and_return(tagable_mock(['nyc', 'oil']))
      expect(Entity).to receive(:find).with('1000')
                          .and_return(tagable_mock(['georgia']))
      tagger.run
    end
  end
end
