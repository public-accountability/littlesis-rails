xdescribe OsMatch, type: :model do
  it { should validate_presence_of(:os_donation_id) }
  it { should validate_presence_of(:donor_id) }
  it { should belong_to(:os_donation) }
  it { should belong_to(:donation).optional }

  RefOne = { name: "FEC Filing 11020480483", url: "http://images.nictusa.com/cgi-bin/fecimg/?11020480483" }
  RefTwo = { name: "FEC Filing 10020853341", url: "http//images.nictusa.com/cgi-bin/fecimg/?10020853341" }

  def model_setup
    @loeb = create(:loeb)
    @nrsc = create(:nrsc)
    @loeb_donation = create(:loeb_donation, entity: @loeb, related: @nrsc) # relationship model
    @loeb_os_donation = create(:loeb_donation_one)
    @loeb_donation.add_reference(RefOne)
    @donation_class = create(:donation, relationship_id: @loeb_donation.id)
    @user = create_basic_user
    @os_match = OsMatch.create(
      os_donation_id: @loeb_os_donation.id,
      donation_id: @donation_class.id,
      donor_id: @loeb.id,
      recip_id: @nrsc.id,
      relationship_id: @loeb_donation.id,
      matched_by: @user.id
    )
  end

  describe 'Associations' do
    before(:all) do
      DatabaseCleaner.start
      OsMatch.skip_callback(:create, :after, :post_process)
      model_setup
    end

    after(:all) do
      DatabaseCleaner.clean
      OsMatch.set_callback(:create, :after, :post_process)
    end

    it 'belongs to donor via entity' do
      expect(@os_match.donor).to eql @loeb
      expect(Entity.find(@loeb.id).matched_contributions).to eq [@os_match]
    end

    it 'Entity joined to OsDonation through OsMatch' do
      expect(Entity.find(@loeb.id).contributions).to eq [@loeb_os_donation]
    end

    it 'belongs to recipient via entity' do
      expect(@os_match.recipient).to eql @nrsc
      expect(Entity.find(@nrsc.id).donors).to eq [@os_match]
    end

    it 'belongs to a relationship' do
      expect(@os_match.relationship).to eql @loeb_donation
      expect(Relationship.find(@loeb_donation.id).os_matches).to eq [@os_match]
    end

    it 'belongs to a user' do
      expect(@os_match.user).to eql @user
    end
  end

  describe '#set_recipient_and_committee' do
    let(:loeb) { create(:loeb) }
    let(:nrsc) { create(:nrsc) }
    let(:elected) { create(:elected) }

    it 'sets committee to be the same as the recipient if the ids are the same' do
      os_donation = create(:loeb_donation_one)
      os_match = OsMatch.create(os_donation_id: os_donation.id, donor_id: loeb.id)
      expect(os_match).to receive(:find_or_create_cmte).and_return(nrsc)
      os_match.set_recipient_and_committee
      expect(os_match.committee).to eql nrsc
      expect(os_match.recipient).to eql nrsc
    end

    it 'sets committee and recipient if different' do
      os_donation = create(:loeb_donation_one, recipid: 'N101')
      os_match = OsMatch.create(os_donation_id: os_donation.id, donor_id: loeb.id)
      expect(os_match).to receive(:find_or_create_cmte).and_return(nrsc)
      expect(os_match).to receive(:find_recip_id).with('N101').and_return(elected.id)
      os_match.set_recipient_and_committee
      expect(os_match.committee).to eql nrsc
      expect(os_match.recipient).to eql elected
    end
  end

  describe '#update_donation_relationship' do
    before(:all) do
      OsMatch.skip_callback(:create, :after, :post_process)
      DatabaseCleaner.start
      @relationship_count = Relationship.count
      @loeb = create(:loeb)
      @nrsc = create(:nrsc)
      @os_donation = create(:loeb_donation_one)
      @os_match = OsMatch.create(os_donation_id: @os_donation.id, donor_id: @loeb.id, recip_id: @nrsc.id)
      @os_match.update_donation_relationship
    end

    after(:all) do
      OsMatch.set_callback(:create, :after, :post_process)
      DatabaseCleaner.clean
    end

    it "creates a new relationship if it doesn't yet exist" do
      expect(Relationship.count).to eql(@relationship_count + 1)
    end

    it 'sets relationship on OsMatch model' do
      expect(@os_match.relationship).not_to be_nil
    end

    it 'sets description 1 & 2 to be campaign contribution' do
      expect(@os_match.relationship.description1).to eql 'Campaign Contribution'
      expect(@os_match.relationship.description2).to eql 'Campaign Contribution'
    end

    it 'updates amount' do
      expect(@os_match.relationship.amount).to eql 30_800
    end

    it 'updates number of filing' do
      expect(@os_match.relationship.filings).to eql 1
    end

    it 'sets start date' do
      expect(@os_match.relationship.start_date).to eql '2011-11-29'
    end

    it 'sets end date' do
      expect(@os_match.relationship.start_date).to eql '2011-11-29'
    end

    it 'does not create a new relationship if called more than once' do
      @os_match.update_donation_relationship
      expect(Relationship.count).to eql (@relationship_count + 1)
      expect(@os_match.relationship.amount).to eql 30_800
      expect(@os_match.relationship.filings).to eql 1
    end

    context 'Another donation affecting the same relationship' do
      before do
        d2 = create(:loeb_donation_one, amount: 10_000, fec_cycle_id: 'blah', date: '2010-02-02')
        @os_match2 = OsMatch.create(os_donation_id: d2.id, donor_id: @loeb.id, recip_id: @nrsc.id)
        @os_match2.update_donation_relationship
      end

      it 'does not create a new relationship' do
        expect(Relationship.count).to eql(@relationship_count + 1)
      end

      it 'finds same relationship' do
        expect(@os_match2.relationship).to eql @os_match.relationship
      end

      it 'updates amount' do
        expect(@os_match.relationship.reload.amount).to eql 40_800
        expect(@os_match2.relationship.amount).to eql 40_800
      end

      it 'updates number of filings' do
        expect(@os_match.relationship.reload.filings).to eql 2
        expect(@os_match2.relationship.filings).to eql 2
      end

      it 'changes start_date' do
        expect(@os_match.relationship.reload.start_date).to eql '2010-02-02'
      end

      it 'keeps same end date' do
        expect(@os_match.relationship.reload.end_date).to eql '2011-11-29'
      end
    end

    context 'the os_donation date is null' do
      it 'handles null date' do
        os_donation = create(:loeb_donation_one, fec_cycle_id: rand(1000), date: nil)
        os_match = OsMatch.create(os_donation_id: os_donation.id, donor_id: @loeb.id, recip_id: @nrsc.id)
        expect { os_match.update_donation_relationship }.not_to raise_error
      end
    end

    context 'The donor has be merged or deleted' do
      let(:donation) { create(:loeb_donation_one, amount: 10_000, fec_cycle_id: 'blah', date: "2010-02-02") }
      let(:loeb_new) { create(:loeb) }
      let(:loeb_old) { create(:loeb, merged_id: loeb_new.id, is_deleted: true) }
      let(:match) { OsMatch.create!(os_donation_id: donation.id, donor_id: loeb_old.id, recip_id: @nrsc.id) }

      it 'changes os_match donor_id' do
        expect(match.donor_id).to eql loeb_old.id
        match.update_donation_relationship
        expect(match.donor_id).to eql loeb_new.id
      end

      it 'creates a new relationship' do
        expect { match.update_donation_relationship }.to change { Relationship.count }.by(1)
      end
    end

    describe '#create_reference' do
      it 'creates 3 references' do
        expect { @os_match.create_reference }.to change(Reference, :count).by(3)
      end

      it 'document has correct info' do
        expect { @os_match.create_reference }.to change(Document, :count).by(1)
        doc = Document.last
        expect(doc.name).to eql "FEC Filing 11020480483"
        expect(doc.url).to eql "http://docquery.fec.gov/cgi-bin/fecimg/?11020480483"
        expect(doc.ref_type).to eq 'fec'
      end

      it 'can be run twice without creating a new reference' do
        expect { 2.times { @os_match.create_reference } }.to change(Reference, :count).by(3)
      end
    end
  end

  describe '#find_recip_id' do
    it "finds recip_id if there's an ElectedRepresentative" do
      elected = create(:elected)
      ElectedRepresentative.create!(crp_id: 'CRPID1', entity_id: elected.id)
      expect(OsMatch.new.find_recip_id('CRPID1')).to eql elected.id
    end

    it "finds id if there's an already existing Political Candidate" do
      elected = create(:elected)
      PoliticalCandidate.create!(crp_id: 'CRPID2', entity_id: elected.id)
      expect(OsMatch.new.find_recip_id('CRPID2')).to eql elected.id
    end

    it 'finds recip_id if a PoliticalFundraising committee exists' do
      pac = create(:pac)
      create(:political_fundraising, fec_id: 'C123', entity_id: pac.id)
      expect(OsMatch.new.find_recip_id('C123')).to eql pac.id
    end

    it 'returns null otherwise' do
      expect(OsMatch.new.find_recip_id('NONEXISTENT')).to be_nil
    end
  end

  describe '#find_or_create_cmte' do
    before(:all) do
      DatabaseCleaner.start
      @nrsc = create(:nrsc, id: 8888)
      @donation = create(:loeb_donation_one, cmteid: ":-<", fec_cycle_id: 'xx')
      @fundraiser = PoliticalFundraising.create(entity_id: @nrsc.id, fec_id: ":-<")
    end

    after(:all) { DatabaseCleaner.clean }

    it 'return entity if a fundraising entity is found' do
      expect(OsMatch.create(os_donation_id: @donation.id).find_or_create_cmte).to eql @nrsc
    end
  end

  describe 'Class Methods' do
    describe 'create_new_cmte' do
      before(:all) do
        DatabaseCleaner.start
        Entity.set_callback(:create, :after, :create_primary_ext)
        @cmte = create(:os_committee)
        @created_entity = OsMatch.create_new_cmte @cmte
        @e = Entity.last
      end

      after(:all) do
        Entity.skip_callback(:create, :after, :create_primary_ext)
        DatabaseCleaner.clean
      end

      it 'creates a new entity' do
        expect(@e.name).to eql 'SuprePac'
      end

      it 'creates ExtensionRecord' do
        expect(@e.extension_records.count).to eql(2)
        expect(@e.extension_records.last.definition_id).to eql(11)
      end

      it 'creates PoliticalFundraising' do
        expect(PoliticalFundraising.where(entity_id: @e.id).count).to eql(1)
        expect(@e.political_fundraising.fec_id).to eql 'C00000042'
      end

      it 'returns the entity' do
        expect(@created_entity).to eql @e
      end

      it 'returns nil if the cmte has no name' do
        committee = build(:os_committee, name: '')
        expect(OsMatch.create_new_cmte committee).to be_nil
        committee = build(:os_committee, name: nil)
        expect(OsMatch.create_new_cmte committee).to be_nil
      end
    end
  end

  describe 'matching and unmatching' do
    let!(:donor) { create(:loeb) }
    # let(:recipient) { create(:entity_org) }
    let(:recip_code) { Faker::Number.number(digits: 5).to_s }
    let(:os_donation) { create(:os_donation, recipid: recip_code, cmteid: recip_code) }
    let(:os_donation_two) { create(:os_donation, recipid: recip_code, cmteid: recip_code, amount: 2) }
    let(:os_committee) { create(:os_committee, cmte_id: recip_code) }
    let(:create_match) do
      proc do |os_donation_id|
        OsMatch.create(os_donation_id: os_donation_id, donor_id: donor.id)
      end
    end

    before(:each) do
      allow(OsCommittee).to receive(:find_by).and_return(os_committee)
    end

    context 'creating a new os match' do
      it 'creates a relationship' do
        expect { create_match.call(os_donation.id) }.to change { Relationship.count }.by(1)
      end

      it 'creates a new entity (from the os_committee)' do
        expect { create_match.call(os_donation.id) }.to change { Entity.count }.by(1)
        expect(Entity.last.name).to eql os_committee.name
        expect(Entity.last.political_fundraising).to be_a PoliticalFundraising
        expect(Entity.last.political_fundraising.fec_id).to eql os_committee.cmte_id
      end
    end

    context 'creating a second match' do
      it 'creates only one relationship' do
        expect { create_match.call(os_donation.id) }.to change { Relationship.count }.by(1)
        expect { create_match.call(os_donation_two.id) }.not_to change { Relationship.count }
      end

      it 'updates amount fields on relationship' do
        create_match.call(os_donation.id)
        create_match.call(os_donation_two.id)
        expect(Relationship.last.amount).to eql 3
      end

      it 'creates new references' do
        expect { create_match.call(os_donation.id) }.to change { Reference.count }.by(3)
        expect { create_match.call(os_donation_two.id) }.to change { Reference.count }.by(3)
      end
    end

    context 'unmatching' do
      before do
        @match1 = create_match.call(os_donation.id)
        @match2 = create_match.call(os_donation_two.id)
      end

      context 'after removing one match' do
        it 'changes amount field on relationship' do
          relationship = @match1.relationship
          expect { @match1.destroy }.to change { relationship.reload.amount }.by(-1)
        end

        it 'changes filing number of relationship' do
          relationship = @match1.relationship
          expect { @match1.destroy }.to change { relationship.reload.filings }.by(-1)
        end

        it 'removes one reference' do
          expect { @match1.destroy }.to change { Reference.count }.by(-1)
        end

        it 'deletes the match' do
          expect { @match1.destroy }.to change { OsMatch.count }.by(-1)
        end
      end

      context 'after removing both matches' do
        it 'soft deletes the relationship' do
          relationship = @match1.relationship
          @match1.destroy
          expect { @match2.destroy }.to change { relationship.reload.is_deleted }.from(false).to(true)
        end

        it 'removes both referneces' do
          expect { @match1.destroy; @match2.destroy }.to change { Reference.count }.by(-2)
        end
      end
    end # end context unmatching
  end
end
