require 'rails_helper'

describe OsMatch, type: :model do
  before(:all) do
    Entity.skip_callback(:create, :after, :create_primary_ext)
    OsMatch.skip_callback(:create, :after, :post_process)
    DatabaseCleaner.start
  end
  after(:all) do
    Entity.set_callback(:create, :after, :create_primary_ext)
    OsMatch.set_callback(:create, :after, :post_process)
    DatabaseCleaner.clean
  end

  it { should validate_presence_of(:os_donation_id) }
  it { should validate_presence_of(:donor_id) }

  def model_setup
    @loeb = create(:loeb)
    @nrsc = create(:nrsc)
    @loeb_donation = create(:loeb_donation) # relationship model
    @loeb_os_donation = create(:loeb_donation_one)
    @loeb_ref_one = create(:loeb_ref_one, object_id: @loeb_donation.id, object_model: 'Relationship')
    @donation_class = create(:donation, relationship_id: @loeb_donation.id)
    @user = create(:user, sf_guard_user_id: 1)
    @os_match = OsMatch.create(
      os_donation_id: @loeb_os_donation.id,
      donation_id: @donation_class.id,
      donor_id: @loeb.id,
      recip_id: @nrsc.id,
      reference_id: @loeb_ref_one.id,
      relationship_id: @loeb_donation.id,
      matched_by: @user.id
    )
  end

  describe 'Associations' do
    before(:all) do
      DatabaseCleaner.start
      model_setup
    end

    after(:all) do
      DatabaseCleaner.clean
    end

    it 'belongs to os_donation' do
      expect(@os_match.os_donation).to eql @loeb_os_donation
      expect(OsDonation.find(@loeb_os_donation.id).os_match).to eql @os_match
    end

    it 'belongs to donation' do
      expect(@os_match.donation).to eql @donation_class
      expect(Donation.find(@donation_class.id).os_matches).to eq [@os_match]
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

    it 'belongs to a reference' do
      expect(@os_match.reference).to eql @loeb_ref_one
      expect(Reference.find(@loeb_ref_one.id).os_match).to eql @os_match
      expect(Reference.find(@loeb_ref_one.id).os_donation).to eql @loeb_os_donation
    end

    it 'belongs to a relationship' do 
      expect(@os_match.relationship).to eql @loeb_donation
      expect(Relationship.find(@loeb_donation.id).os_matches).to eq [@os_match]
    end

    it 'belongs to a user' do
      expect(@os_match.user).to eql @user
    end

    it 'requires os_donation_id' do
      os_match = OsMatch.new(donor_id: 123)
      expect(os_match.valid?).to be false
      os_match.os_donation_id = 1
      expect(os_match.valid?).to be true
    end

    it 'requires donor_id' do
      os_match = OsMatch.new(os_donation_id: 10)
      expect(os_match.valid?).to be false
      os_match.donor_id = 1
      expect(os_match.valid?).to be true
    end
  end

  describe '#set_recipient_and_committee' do
    before(:all) do
      DatabaseCleaner.start
      @loeb = create(:loeb)
      @nrsc = create(:nrsc)
      @elected = create(:elected)
    end

    after(:all) do
      DatabaseCleaner.clean
    end

    it 'sets committee to be the same as the recipient if the ids are the same'do
      os_donation = create(:loeb_donation_one)
      os_match = OsMatch.create(os_donation_id: os_donation.id, donor_id: @loeb.id)
      expect(os_match).to receive(:find_or_create_cmte).and_return(@nrsc)
      os_match.set_recipient_and_committee
      expect(os_match.committee).to eql @nrsc
      expect(os_match.recipient).to eql @nrsc
    end

    it 'sets committee and recipient if different' do 
      os_donation = create(:loeb_donation_one, recipid: 'N101')
      os_match = OsMatch.create(os_donation_id: os_donation.id, donor_id: @loeb.id)
      expect(os_match).to receive(:find_or_create_cmte).and_return(@nrsc)
      expect(os_match).to receive(:find_recip_id).with('N101').and_return(@elected.id)
      os_match.set_recipient_and_committee
      expect(os_match.committee).to eql @nrsc
      expect(os_match.recipient).to eql @elected
    end
  end

  describe '#update_donation_relationship' do
    before(:all) do
      DatabaseCleaner.start
      @relationship_count = Relationship.count
      @loeb = create(:loeb)
      @nrsc = create(:nrsc)
      @os_donation = create(:loeb_donation_one)
      @os_match = OsMatch.create(os_donation_id: @os_donation.id, donor_id: @loeb.id, recip_id: @nrsc.id)
      @os_match.update_donation_relationship
    end

    after(:all) do
      DatabaseCleaner.clean
    end

    it "creates a new relationship if it doesn't yet exist" do
      expect(Relationship.count).to eql (@relationship_count + 1)
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
        expect(Relationship.count).to eql (@relationship_count + 1)
      end

      it 'finds same relationship' do
        expect(@os_match2.relationship).to eql @os_match.relationship
      end

      it 'updates amount'do
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
      before do
        DatabaseCleaner.start
        donation = create(:loeb_donation_one, amount: 10000, fec_cycle_id: 'blah', date: "2010-02-02")
        @loeb_new = create(:loeb, id: rand(10000) )
        @loeb_old = create(:loeb, merged_id: @loeb_new.id, id: rand(1000), is_deleted: true)
        @match = OsMatch.create(os_donation_id: donation.id, donor_id: @loeb_old.id, recip_id: @nrsc.id)
      end
      after { DatabaseCleaner.clean }

      it 'changes os_match donor_id' do
        expect(@match.donor_id).to eql @loeb_old.id
        @match.update_donation_relationship
        expect(@match.donor_id).to eql @loeb_new.id
      end

      it 'creates a new relationship' do 
        expect { @match.update_donation_relationship }.to change {Relationship.count}.by(1)
      end
    end

    describe '#create_reference'do
      before(:all) do
        DatabaseCleaner.start
        @ref_count = Reference.count
        @os_match.create_reference
        @ref = Reference.last
      end

      after(:all) do
        DatabaseCleaner.clean
      end

      it 'creates a new reference' do
        expect(Reference.count).to eql (@ref_count + 1)
      end

      it 'Reference has correct info' do
        expect(@ref.name).to eql "FEC Filing 11020480483"
        expect(@ref.source).to eql "http://docquery.fec.gov/cgi-bin/fecimg/?11020480483"
        expect(@ref.object_model).to eql "Relationship"
        expect(@ref.object_id).to eql @os_match.relationship.id
        expect(@ref.ref_type).to eql 2
      end

      it 'sets reference association on OsMatch' do
        expect(@os_match.reload.reference).to eql @ref
      end

      it 'can be run twice without creating a new reference' do
        @os_match.create_reference
        expect(Reference.count).to eql (@ref_count + 1)
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

    after(:all) do
      DatabaseCleaner.clean
    end
    
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

     #   describe 'match_a_donation' do
     #     it 'creates new OsMatch' do 
     #       count = OsMatch.count
     #       OsMatch.match_a_donation 123, 456
     #       expect(OsMatch.count).to eql (count + 1)
     #       expect(OsMatch.last.os_donation_id).to eql 123
     #       expect(OsMatch.last.donor_id).to eql 456
     #     end
     #   end
   end

   # describe 'softDelete' do
   #   before(:all) do 
   #     @count = OsMatch.count
   #     @os_match = OsMatch.create(os_donation_id: 123, donor_id: 123)
   #   end
     
   #   it 'increases os match count' do
   #     expect(OsMatch.count).to eql (@count + 1)
   #   end
     
   #   it 'returns os match count to regular state after soft delete' do 
   #     @os_match.destroy
   #     expect(OsMatch.count).to eql @count
   #   end
     
   #   it 'finds all os matches if unscoped' do 
   #     expect(OsMatch.unscoped.count).to eql (@count + 1)
   #   end
   # end

   describe 'unmatch' do
     before(:all) do
       DatabaseCleaner.start
       @loeb = create(:loeb)
       @nrsc = create(:nrsc)
       @loeb_donation = create(:loeb_donation) # relationship model
       @loeb_os_donation = create(:loeb_donation_one)
       @loeb_os_donation_two = create(:loeb_donation_two)
       @loeb_ref_one = create(:loeb_ref_one, object_id: @loeb_donation.id, object_model: "Relationship")
       @loeb_ref_two = create(:loeb_ref_two, object_id: @loeb_donation.id, object_model: "Relationship")
       # @donation_class = create(:donation, relationship_id: @loeb_donation.id)
       @os_match = OsMatch.create(
         os_donation_id: @loeb_os_donation.id,
         donor_id: @loeb.id,
         recip_id: @nrsc.id,
         reference_id: @loeb_ref_one.id,
         relationship_id: @loeb_donation.id)
       @os_match_2 = OsMatch.create(
         os_donation_id: @loeb_os_donation_two.id,
         donor_id: @loeb.id,
         recip_id: @nrsc.id,
         reference_id: @loeb_ref_two.id,
         relationship_id: @loeb_donation.id)
       @loeb_donation.update_os_donation_info
     end

     after(:all) do
       DatabaseCleaner.clean
     end

     it 'relationship has two matches' do 
       expect(Relationship.find(@loeb_donation.id).amount).to eql 61200
       expect(Relationship.find(@loeb_donation.id).filings).to eql 2
     end

     context 'after destroying os_match_2' do
       before(:all) do
         @count = OsMatch.count
         @os_match_2.destroy
       end

       it 'updates the relationship if relationship still has matches' do
         expect(Relationship.find(@loeb_donation.id).filings).to eql 1
       end

       it 'destroys the reference' do
         expect(Reference.where(id: @loeb_ref_two.id).exists?).to be false
       end

       it 'deletes the match' do
         expect(OsMatch.where(id: @os_match_2.id).exists?).to be false
         expect(OsMatch.count).to eql (@count - 1)
       end 
     end

     context 'after destroying Os_match' do
       before(:all) do
         @count = OsMatch.count
         @os_match.destroy
       end

       it 'destroys the relationship if the match was the only one' do
         expect(Relationship.where(id: @loeb_donation.id).exists?).to be false
         expect(Relationship.unscoped.find(@loeb_donation.id).is_deleted).to be true
       end

       it 'destroys the donation-class model' do
         expect(Donation.where(id: @loeb_donation.donation.id).exists?).to be false
       end

       it 'deletes associated links' do
         expect(Relationship.unscoped.find(@loeb_donation.id).links).to be_empty
       end

       it 'destroys the reference' do
         expect(Reference.where(id: @loeb_ref_one.id).exists?).to be false
       end

       it 'deletes the match' do
         expect(OsMatch.where(id: @os_match.id).exists?).to be false
         expect(OsMatch.count).to eql(@count - 1)
       end
     end
   end
end
