describe ExternalLink, type: :model do
  let(:urls) do
    { ruby: 'https://en.wikipedia.org/wiki/Ruby_(programming_language)',
      rails: 'https://en.wikipedia.org/wiki/Ruby_on_Rails' }
  end

  it { is_expected.to have_db_column(:link_type) }
  it { is_expected.to have_db_column(:entity_id) }
  it { is_expected.to have_db_column(:link_id) }
  it { is_expected.to belong_to(:entity) }

  describe 'LINK_TYPE_IDS' do
    specify do
      expect(ExternalLink::LINK_TYPE_IDS.fetch(2))
        .to eq 'wikipedia'
    end
  end

  describe 'validation of multiple' do
    let(:entity) { create(:entity_org) }

    it 'does not allow multiple wikipedia links for the same entity' do
      entity.external_links.create!(link_type: :wikipedia, link_id: urls[:ruby])
      expect(entity.external_links.count).to eq 1

      expect { entity.external_links.create!(link_type: :wikipedia, link_id: urls[:rails]) }
        .to raise_error(ActiveRecord::RecordNotUnique)
    end

    it 'allows multiple crd numbers for the same entity' do
      entity.external_links.create!(link_type: :crd, link_id: '12345')

      expect(entity.external_links.count).to eq 1

      expect { entity.external_links.create!(link_type: :crd, link_id: '56789') }
        .not_to raise_error

      expect(entity.external_links.count).to eq 1
    end
  end

  it 'determines if the links can be edited' do
    expect(build(:sec_external_link).editable?).to be false
    expect(build(:wikipedia_external_link).editable?).to be true
  end

  describe 'sec links' do
    let(:el) { build(:sec_external_link) }

    describe '#url' do
      it 'returns the sec link' do
        expect(el.url).to eql "https://www.sec.gov/cgi-bin/browse-edgar?action=getcompany&CIK=#{el.link_id}&output=xml"
      end
    end
  end

  describe 'wikipedia links' do
    it 'can handles input of wikipedia links' do
      el = build(:wikipedia_external_link, link_id: urls[:ruby])
      el.validate
      expect(el.link_id).to eql 'Ruby_(programming_language)'
    end
  end

  describe 'twitter links' do
    context 'with twitter url' do
      let(:url) { 'https://twitter.com/walmArt' }

      specify do
        el = build(:twitter_external_link, link_id: url)
        el.validate
        expect(el.link_id).to eql 'walmArt'
      end
    end

    context 'with twitter username' do
      let(:username) { '@walmArt' }

      specify do
        el = build(:twitter_external_link, link_id: username)
        el.validate
        expect(el.link_id).to eql 'walmArt'
      end
    end
  end
end
