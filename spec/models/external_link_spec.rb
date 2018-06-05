require 'rails_helper'

describe ExternalLink, type: :model do
  it { is_expected.to have_db_column(:link_type) }
  it { is_expected.to have_db_column(:entity_id) }
  it { is_expected.to have_db_column(:link_id) }
  it { is_expected.to belong_to(:entity) }

  it 'does not allow multiple links of the same type'

  context 'sec links' do
    let(:el) { build(:sec_external_link) }

    describe '#url' do
      it 'returns the sec link' do
        expect(el.url).to eql "https://www.sec.gov/cgi-bin/browse-edgar?action=getcompany&CIK=#{el.link_id}&output=xml"
      end
    end
  end
end
