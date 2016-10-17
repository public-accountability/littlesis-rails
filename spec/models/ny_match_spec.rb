require 'rails_helper'

describe NyMatch, type: :model do

  before(:all) do 
    Entity.skip_callback(:create, :after, :create_primary_ext)
    DatabaseCleaner.start
  end
  
  after(:all) do 
    Entity.set_callback(:create, :after, :create_primary_ext)
    DatabaseCleaner.clean
  end
  
  it { should validate_presence_of(:ny_disclosure_id) }
  it { should validate_presence_of(:donor_id) }
  it { should belong_to(:ny_disclosure) }
  it { should belong_to(:donor) }
  it { should belong_to(:recipient) }
  it { should belong_to(:relationship) }
  it { should belong_to(:user) }
  it { should have_one(:ny_filer) }
  it { should have_one(:ny_filer_entity) }

  describe 'match' do 
    
    before(:each) do 
      expect(NyFilerEntity).to receive(:find_by_filer_id).and_return(double(:entity_id => 100))
      allow(Relationship).to receive(:find_or_create_by!).and_return(build(:relationship))
    end

    it 'Creates a new match' do 
      d = create(:ny_disclosure)
      expect{NyMatch.match(d.id,1,1)}.to change{NyMatch.count}.by(1)
    end
    
    it 'Creates match with correct attributes' do 
      d = create(:ny_disclosure)
      NyMatch.match(d.id,50,42)
      m = NyMatch.last
      expect(m.ny_disclosure_id).to eql d.id
      expect(m.donor_id).to eql 50
      expect(m.matched_by).to eql 42
    end
    
    it 'Sets matched_by to be the system_user_id if no user is given' do 
      d = create(:ny_disclosure)
      NyMatch.match(d.id,20)
      expect(NyMatch.last.matched_by).to eql 1
    end

    it 'Does not create a new match if the match already exits' do 
      d = create(:ny_disclosure)
      expect { NyMatch.match(d.id,20) }.to change{NyMatch.count}.by(1)
      expect(NyMatch.last.ny_disclosure).to eql d
      expect(NyMatch.last.matched_by).to eql 1
      expect{ NyMatch.match(d.id, 20, 55) }.not_to change{NyMatch.count}
      expect(NyMatch.last.matched_by).to eql 1
    end

  end

  describe 'set_recipient' do 
    
    it 'sets recip_id' do 
      disclosure = create(:ny_disclosure, filer_id: 'X1')
      elected = create(:elected)
      create(:ny_filer_entity, filer_id: 'X1', entity_id: elected.id)
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
    
    before(:all) do 
      @donor = create(:person)
      @elected = create(:elected)
    end
    
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
        match = NyMatch.create(ny_disclosure_id: disclosure.id, donor: @donor, recipient: @elected)
        expect{ match.create_or_update_relationship  }.to change{Relationship.count}.by(1)
        expect(match.relationship).to eql Relationship.last
        expect(match.relationship.amount).to eql 50
        expect(match.relationship.filings).to eql 1
        expect(match.relationship.category_id).to eql 5
        disclosure = create(:ny_disclosure, amount1: 200)
        match = NyMatch.create(ny_disclosure_id: disclosure.id, donor: @donor, recipient: @elected)
        expect{ match.create_or_update_relationship  }.not_to change{Relationship.count}
        expect(match.relationship.amount).to eql 250
        expect(match.relationship.filings).to eql 2
      end
    end
   end

end
