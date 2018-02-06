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
        org.extension_records.where('definition_id <> 2').first.versions.count
      ).to eql 1
    end
  end
end
