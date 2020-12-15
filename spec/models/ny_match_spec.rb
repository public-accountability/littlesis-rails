# rubocop:disable RSpec/VerifiedDoubles

describe NyMatch, type: :model do
  it { is_expected.to validate_presence_of(:ny_disclosure_id) }
  it { is_expected.to validate_presence_of(:donor_id) }
  it { is_expected.to belong_to(:ny_disclosure) }
  it { is_expected.to belong_to(:donor) }
  it { is_expected.to belong_to(:recipient).optional }
  it { is_expected.to belong_to(:relationship).optional }
  it { is_expected.to belong_to(:user).optional }
  it { is_expected.to have_one(:ny_filer) }
  it { is_expected.to have_one(:ny_filer_entity) }

  describe 'match' do
    def rel
      build(:relationship).tap { |r| allow(r).to receive(:add_reference) }
    end

    context 'creating new matches' do
      let(:disclosure) { create(:ny_disclosure) }

      before do
        expect(NyFilerEntity).to receive(:find_by).and_return(double(:entity_id => 100))
        allow(Relationship).to receive(:find_or_create_by!).and_return(rel)
      end

      it 'Creates a new match' do
        expect { NyMatch.match(disclosure.id, 1, 1) }.to change(NyMatch, :count).by(1)
      end

      it 'Creates match with correct attributes' do
        NyMatch.match(disclosure.id, 50, 42)
        m = NyMatch.last
        expect(m.ny_disclosure_id).to eql disclosure.id
        expect(m.donor_id).to eq 50
        expect(m.matched_by).to eq 42
      end

      it 'Sets matched_by to be the system_user_id if no user is given' do
        NyMatch.match(disclosure.id, 20)
        expect(NyMatch.last.matched_by).to eq 1
      end

      it 'Does not create a new match if the match already exits' do
        expect { NyMatch.match(disclosure.id, 20) }.to change(NyMatch, :count).by(1)
        expect(NyMatch.last.ny_disclosure).to eql disclosure
        expect(NyMatch.last.matched_by).to eq 1
        expect { NyMatch.match(disclosure.id, 20, 55) }.not_to change(NyMatch, :count)
        expect(NyMatch.last.matched_by).to eq 1
      end
    end

    it 'updates updated_at for recipient' do
      allow(Relationship).to receive(:find_or_create_by!).and_return(rel)
      elected = create(:elected)
      elected.update_column(:updated_at, 1.day.ago)
      expect(NyFilerEntity).to receive(:find_by).and_return(double(:entity_id => elected.id ))
      d = create(:ny_disclosure)
      expect { NyMatch.match(d.id, 10) }. to change { Entity.find(elected.id).updated_at }
    end
  end

  describe 'matching then un matching' do
    let(:filer_id) { SecureRandom.hex(2) }
    let(:donor) { create(:entity_person) }
    let(:nys_politician) { create(:entity_person) }
    let(:ny_disclosures) { Array.new(2) { create(:ny_disclosure, filer_id: filer_id) } }
    let(:disclosure_sum) { ny_disclosures.reduce(0) { |sum, d| (sum + d.amount1) } }
    let(:ny_filer) { create(:ny_filer) }

    let!(:ny_filer_entity) do
      NyFilerEntity.create!(filer_id: filer_id, entity_id: nys_politician.id, ny_filer: ny_filer)
    end

    let(:create_matches) do
      proc { ny_disclosures.map(&:id).map { |i| NyMatch.match(i, donor.id) } }
    end

    it 'creates a relationship after matching both disclosures' do
      expect(Relationship.where(entity1_id: donor.id, entity2_id: nys_politician.id).count).to be_zero
      matches = create_matches.call
      expect(Relationship.where(entity1_id: donor.id, entity2_id: nys_politician.id).count).to eq 1
      rel = Relationship.find(matches.first.relationship_id)
      expect(rel.amount).to eq disclosure_sum
      expect(rel.filings).to eql 2
      matches.each { |m| expect(m.recip_id).to eql(nys_politician.id) }
    end

    it 'changes relationship after removing one match' do
      matches = create_matches.call
      expect(Relationship.where(entity1_id: donor.id, entity2_id: nys_politician.id).count).to eq 1
      expect { matches.first.unmatch! }.to change(NyMatch, :count).by(-1)
      expect(Relationship.where(entity1_id: donor.id, entity2_id: nys_politician.id).count).to eq 1
      rel = Relationship.find(matches.first.relationship_id)
      expect(rel.amount).to eq(disclosure_sum - matches.first.ny_disclosure.amount1)
    end

    it 'removes the relationship after removing both matches' do
      matches = create_matches.call
      expect(Relationship.where(entity1_id: donor.id, entity2_id: nys_politician.id).count).to eq 1
      expect { matches.each(&:unmatch!) }.to change(NyMatch, :count).by(-2)
      expect(Relationship.where(entity1_id: donor.id, entity2_id: nys_politician.id).count).to be_zero
    end

  end

  describe 'set_recipient' do
    it 'sets recip_id' do
      ny_filer = create(:ny_filer)
      disclosure = create(:ny_disclosure, ny_filer: ny_filer)
      elected = create(:entity_person)
      NyFilerEntity.create!(ny_filer: ny_filer, entity: elected, filer_id: ny_filer.filer_id)
      m = NyMatch.new(ny_disclosure_id: disclosure.id, donor_id: 123)
      expect(m.recipient).to be nil
      m.set_recipient
      expect(m.recipient).to eql elected
    end

    it 'sets recip_id to nil if there is no FilerEntity for the disclosure' do
      disclosure = create(:ny_disclosure, filer_id: 'X1')
      m = NyMatch.new(ny_disclosure_id: disclosure.id, donor_id: 123)
      expect(m.recipient).to be nil
      m.set_recipient
      expect(m.recipient).to be nil
    end
  end

  describe 'create_or_update_relationship' do
    let(:donor) { create(:entity_person) }
    let(:elected) { create(:elected) }

    it 'returns nil if relationship if nil' do
      expect(NyMatch.new(relationship_id: 123).create_or_update_relationship).to be nil
    end

    it 'returns nil if donor_id is nil' do
      expect(NyMatch.new(recip_id: 123).create_or_update_relationship).to be nil
    end

    it 'returns nil if recip_id is nil' do
      expect(NyMatch.new(donor_id: 123).create_or_update_relationship).to be nil
    end

    describe 'creating and updating the same relationship' do
      it 'creates a new relationship, and then updates it.' do
        disclosure = create(:ny_disclosure, amount1: 50)
        match = NyMatch.create(ny_disclosure_id: disclosure.id, donor: donor, recipient: elected)
        expect { match.create_or_update_relationship }.to change(Relationship, :count).by(1)
        expect(match.relationship).to eql Relationship.last
        expect(match.relationship.amount).to eq 50
        expect(match.relationship.filings).to eq 1
        expect(match.relationship.category_id).to eq 5
        disclosure = create(:ny_disclosure, amount1: 200)
        match = NyMatch.create(ny_disclosure_id: disclosure.id, donor: donor, recipient: elected)
        expect { match.create_or_update_relationship }.not_to change(Relationship, :count)
        expect(match.relationship.amount).to eq 250
        expect(match.relationship.filings).to eq 2
      end
    end

    it "sets the relationship's last_user id to be the matched_by user" do
      disclosure = create(:ny_disclosure, amount1: 50)
      user = create_really_basic_user
      match = NyMatch.create(ny_disclosure_id: disclosure.id, donor: donor, recipient: elected, matched_by: user.id)
      match.create_or_update_relationship
      expect(Relationship.last.last_user_id).to eql user.id
    end

    it "sets the relationship's last_user id to default to be 1" do
      disclosure = create(:ny_disclosure, amount1: 50)
      match = NyMatch.create(ny_disclosure_id: disclosure.id, donor: donor, recipient: elected)
      match.create_or_update_relationship
      expect(Relationship.last.last_user_id).to eq 1
    end

    context 'when ny match was created a while ago' do
      it "sets the relationship's last_user id to be the system user id" do
        disclosure = create(:ny_disclosure, amount1: 50)
        user = create_really_basic_user
        match = NyMatch.create!(ny_disclosure_id: disclosure.id, donor: donor, matched_by: user.id)
        match.update_column(:updated_at, 1.hour.ago)
        expect(NyFilerEntity).to receive(:find_by)
                                   .with(filer_id: disclosure.filer_id)
                                   .and_return(build(:ny_filer_entity, entity_id: elected.id))
        match.rematch
        expect(Relationship.last.last_user_id).to eq 1
      end
    end

    it 'creates a new reference' do
      disclosure = create(:ny_disclosure, amount1: 50)
      match = NyMatch.create(ny_disclosure_id: disclosure.id, donor: donor, recipient: elected)
      expect { match.create_or_update_relationship }.to change(Reference, :count).by(3)
      expect(Reference.last.document.url).to eq disclosure.reference_link
      expect(Reference.last.document.name).to eq disclosure.reference_name
    end
  end

  describe '#info' do
    subject(:match) { create(:ny_match, ny_disclosure: disclosure, donor: donor, recipient: elected) }

    let(:donor) { build(:person) }
    let(:elected) { build(:elected) }
    let(:filer) { build(:ny_filer, filer_id: '9876', name: 'some committee') }
    let(:disclosure) { build(:ny_disclosure, amount1: 50, ny_filer: filer) }

    it 'returns a hash' do
      expect(match.info).to be_a(Hash)
    end

    it 'has ny_disclosure keys' do
      [:name, :address, :date, :amount, :filer_id, :filer_name, :transaction_code, :disclosure_id].each do |k|
        expect(match.info).to have_key(k)
      end
    end

    it 'has key filer_in_littlesis' do
      expect(match.info).to have_key(:filer_in_littlesis)
    end

    it 'has key ny_match_id' do
      expect(match.info.fetch(:ny_match_id)).to eql match.id
    end
  end

  describe '#create_reference' do
    let(:donor) { create(:entity_person) }
    let(:elected) { create(:elected) }
    let(:filer) { build(:ny_filer, filer_id: '9876', name: 'some committee') }
    let(:disclosure) { build(:ny_disclosure, amount1: 50, ny_filer: filer, e_year: '2017', report_id: 'B') }
    let(:rel) { create(:relationship, category_id: 5, entity: donor, related: elected, amount: 1000, description1: "NYS Campaign Contribution" ) }
    let(:url) { Faker::Internet.url }

    it 'adds the ny disclosure referece link' do
      expect(disclosure).to receive(:reference_link).and_return(url)
      match = create(:ny_match, ny_disclosure: disclosure, donor: donor, recipient: elected)
      expect { match.send(:create_reference, rel) }.to change(Reference, :count).by(3)
      expect(Reference.last.document.url).to eql url
    end

    it 'creates a second reference and document if the url is different' do
      expect(disclosure).to receive(:reference_link).and_return('http://ny_state_ref_link_1.gov')
      expect(disclosure).to receive(:reference_link).and_return('http://ny_state_ref_link_2.gov')
      match = create(:ny_match, ny_disclosure: disclosure, donor: donor, recipient: elected)

      expect { match.send(:create_reference, rel) }.to change(Reference, :count).by(3)
      expect(Reference.last.document.url).to eq 'http://ny_state_ref_link_1.gov'
      expect { match.send(:create_reference, rel) }.to change(Reference, :count).by(3)
      expect(Reference.last.document.url).to eq 'http://ny_state_ref_link_2.gov'
    end

    it 'does not create a second reference if the url is the same' do
      expect(disclosure).to receive(:reference_link).twice.and_return(url)
      match = create(:ny_match, ny_disclosure: disclosure, donor: donor, recipient: elected)

      expect { match.send(:create_reference, rel) }.to change(Reference, :count).by(3)
      expect { match.send(:create_reference, rel) }.not_to change(Reference, :count)
    end
  end
end

# rubocop:enable RSpec/VerifiedDoubles
