describe ExternalLink, type: :model do
  subject { build(:wikipedia_external_link) }

  let(:urls) do
    { ruby: 'https://en.wikipedia.org/wiki/Ruby_(programming_language)',
      rails: 'https://en.wikipedia.org/wiki/Ruby_on_Rails' }
  end

  it { is_expected.to have_db_column(:link_type) }
  it { is_expected.to have_db_column(:entity_id) }
  it { is_expected.to have_db_column(:link_id) }
  it { is_expected.to belong_to(:entity) }

  describe 'validation of multiple' do
    let(:entity) { create(:entity_org) }

    it 'does not allow multiple wikipedia links for the same entity' do
      entity.external_links.create!(link_type: :wikipedia, link_id: urls[:ruby])
      expect(entity.external_links.count).to eq 1

      expect { entity.external_links.create!(link_type: :wikipedia, link_id: urls[:rails]) }
        .to raise_error(ActiveRecord::RecordInvalid)
    end

    it 'allows multiple crd numbers for the same entity' do
      entity.external_links.create!(link_type: :crd, link_id: '12345')

      expect(entity.external_links.count).to eq 1

      expect { entity.external_links.create!(link_type: :crd, link_id: '56789') }
        .not_to raise_error

      expect(entity.external_links.count).to eq 2
    end
  end

  it 'determines if the links can be edited' do
    expect(build(:sec_external_link).editable?).to be false
    expect(build(:wikipedia_external_link).editable?).to be true
  end

  it 'links can be marked as internal' do
    expect(build(:sapi_link_org).internal?).to be true
    expect(build(:sec_external_link).internal?).to be false
  end

  it 'fails to create a link of type "reserved"' do
    expect { ExternalLink.create!(entity_id: 1, link_type: :reserved, link_id: 'foo') }
      .to raise_error(TypeError)
  end

  describe 'urls' do
    let(:sec_elink) { build(:sec_external_link) }
    let(:crd_org_elink) { build(:crd_external_link_org) }
    let(:crd_person_elink) { build(:crd_external_link_person) }

    it 'returns the sec link' do
      expect(sec_elink.url).to eql "https://www.sec.gov/cgi-bin/browse-edgar?action=getcompany&CIK=#{sec_elink.link_id}&output=xml"
    end

    it 'returns the crd url for an org' do
      expect(crd_org_elink.url)
        .to eq "https://adviserinfo.sec.gov/Firm/#{crd_org_elink.link_id}"
    end

    it 'returns the crd url for a person' do
      expect(crd_person_elink.url)
        .to eq "https://adviserinfo.sec.gov/Individual/#{crd_person_elink.link_id}"
    end
  end

  describe 'wikipedia links' do
    it 'can handles input of wikipedia links' do
      el = build(:wikipedia_external_link, link_id: urls[:ruby])
      el.validate
      expect(el.link_id).to eq 'Ruby_(programming_language)'
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

  describe 'nys filer ids' do
    let(:filer_id) { 'A123' }

    specify do
      expect(build(:nys_filer_link_org, link_id: filer_id).url)
        .to eq 'https://cfapp.elections.ny.gov/ords/plsql_browser/getfiler2_loaddates?filerid_IN=A123'
    end
  end

  describe 'info' do
    specify do
      expect(ExternalLink.info(1)).to eq ['sec', ExternalLink::LINK_TYPES[:sec]]
    end

    specify do
      expect(ExternalLink.info(:sec)).to eq ['sec', ExternalLink::LINK_TYPES[:sec]]
    end

    specify do
      expect(ExternalLink.info('sec')).to eq ['sec', ExternalLink::LINK_TYPES[:sec]]
    end
  end

  describe 'find_or_initialize_links_for' do
    let(:entity) { build(:entity_org) }
    let(:links) { ExternalLink.find_or_initialize_links_for(entity) }

    it 'returns two editable links' do
      expect(links.length).to eq 2
    end

    it 'returns wikipedia and twitter links' do
      expect(links.map(&:link_type).to_set).to eq %w[wikipedia twitter].to_set
    end
  end
end
