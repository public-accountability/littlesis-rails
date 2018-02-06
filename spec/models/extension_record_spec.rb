require 'rails_helper'

describe ExtensionRecord, type: :model do
  it { is_expected.to belong_to :entity }
  it { is_expected.to belong_to :extension_definition }

  with_versioning do
    let(:org) { create(:entity_org) }
    let(:person) { create(:entity_person) }

    it 'does not track Org and People extensions' do
      expect(org.extension_records.first.versions).to be_empty
      expect(person.extension_records.first.versions).to be_empty
    end

    it 'tracks all other extensions' do
      org.add_extension('IndustryTrade')
      expect(
        org.extension_records.find_by('definition_id <> 2').versions.count
      ).to eql 1
    end

    it 'stores associated entity id in entity1_id' do
      org.add_extension('IndustryTrade')
      expect(
        org.extension_records.find_by('definition_id <> 2').versions.first.entity1_id
      ).to eql org.id
    end
  end
end
