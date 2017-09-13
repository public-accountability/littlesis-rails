require 'rails_helper'
require 'csv'
require Rails.root.join('lib', 'task-helpers', 'bulk_tagger.rb')

describe 'BulkTagging' do
  let(:csv) { '' }
  before(:each) do
    allow(File).to receive(:open).and_return(double(:read => csv))
  end

  context 'Tagging entites' do
    let(:csv) do
      CSV.generate do |csv|
        csv << ['entity_url', 'tags', 'tag_all_related']
        csv << ['https://littlesis.org/org/123/org_name', 'nyc', '']
        csv << ['https://littlesis.org/org/456-org_name', 'oil', 'Y']
        csv << ['/person/789-person_name', 'nyc oil', 'TRUE']
        csv << ['http://littlesis.org/person/1000/person_name', 'georgia', '']
      end
    end

    let(:tagger) { BulkTagger.new('tags.csv', :entity) }

    def tagable_mock(tags)
      double('tagable').tap do |double|
        tags.each { |t| expect(double).to receive(:tag).with(t) }
      end
    end

    it 'tags entities with the provided tags' do
      expect(tagger).to receive(:tag_related_entities).twice
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

    def entity_whose_related_entities_will_be_tagged(tags)
      entity = tagable_mock(tags)
      mock_links = [ build(:link), build(:link) ]
      expect(entity).to receive(:links).and_return(mock_links)
      mock_links.each do |link|
        other_entity = build(:org)
        expect(Entity).to receive(:find).with(link.entity2_id).and_return(other_entity)
        tags.each { |t| expect(other_entity).to receive(:tag).with(t) }
      end
      entity
    end

    it 'tags all related entities' do
      expect(Entity).to receive(:find).with('123').and_return(tagable_mock(['nyc']))
      expect(Entity).to receive(:find).with('456')
                          .and_return(entity_whose_related_entities_will_be_tagged(['oil']))
      expect(Entity).to receive(:find).with('789')
                          .and_return(entity_whose_related_entities_will_be_tagged(['nyc', 'oil']))
      expect(Entity).to receive(:find).with('1000').and_return(spy)
      tagger.run
    end
  end

  context 'Tagging lists' do
    let(:tagger) { BulkTagger.new('tags.csv', :list) }
    let(:csv) do
      CSV.generate do |csv|
        csv << ['list_url', 'tags', 'tag_all_in_list']
        csv << ["https://littlesis.org/lists/1232-donor-crossover-list-1234/members", 'nyc', '']
        csv << ["https://littlesis.org/lists/152-austerity-puppetmasters", 'oil', '']
        csv << ["/lists/1327-cofina-plaintiffs-likely-parent-companies/members", 'georgia oil', 'YES']
      end
    end

    it 'tags lists' do
    end
  end
end
