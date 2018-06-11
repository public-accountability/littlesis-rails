require 'rails_helper'

describe ExternalLink, type: :model do
  it { is_expected.to have_db_column(:link_type) }
  it { is_expected.to have_db_column(:entity_id) }
  it { is_expected.to have_db_column(:link_id) }
  it { is_expected.to belong_to(:entity) }

  it 'does not allow multiple links of the same type'

  it 'determines if the links can be edited' do
    expect(build(:sec_external_link).editable?).to be false
    expect(build(:wikipedia_external_link).editable?).to be true
  end

  context 'sec links' do
    let(:el) { build(:sec_external_link) }

    describe '#url' do
      it 'returns the sec link' do
        expect(el.url).to eql "https://www.sec.gov/cgi-bin/browse-edgar?action=getcompany&CIK=#{el.link_id}&output=xml"
      end
    end
  end

  context 'wikipedia links' do
    let(:url) { 'https://en.wikipedia.org/wiki/Ruby_(programming_language)' }
    it 'can handles input of wikipedia links' do
      el = build(:wikipedia_external_link, link_id: url)
      el.validate
      expect(el.link_id).to eql 'Ruby_(programming_language)'
    end
  end
end
