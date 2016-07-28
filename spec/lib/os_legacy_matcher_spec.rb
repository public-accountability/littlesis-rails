require 'rails_helper'

describe 'OsLegacyMatcher' do 
  before(:all) do 
    DatabaseCleaner.start
    Entity.skip_callback(:create, :after, :create_primary_ext)
    @loeb = create(:loeb)
    @nrsc = create(:nrsc)
    @relationship = create(:loeb_donation)
    @filing_one = create(:loeb_filing_one, relationship_id: @relationship.id)
    @filing_two = create(:loeb_filing_two, relationship_id: @relationship.id)
    @donation_one = create(:loeb_donation_one)
    @donation_two = create(:loeb_donation_two)
    @ref_one = create(:loeb_ref_one, object_id: @relationship.id)
    @matcher = OsLegacyMatcher.new @relationship.id
  end
  
  after(:all) do
    Entity.set_callback(:create, :after, :create_primary_ext)
    DatabaseCleaner.clean
  end
  
  describe '#initialize' do
    it 'stores relationship id in instance var' do 
      expect(@matcher.relationship_id).to eql @relationship.id
    end
  end

  describe '#find_filing' do
    it 'finds 2 filings' do 
      @matcher.find_filing
      expect(@matcher.filings.count).to eql(2)
    end
  end

  describe '#corresponding_os_donation' do
    
    it 'finds the donation if the fec id & cycle matches' do 
      filing = build(:loeb_filing_one, fec_filing_id: '1120620120011115314')
      filing_found = @matcher.corresponding_os_donation(filing)
      expect(filing_found).to eq(@donation_one)
    end
    
    it 'finds the donation if the fec_filing_id is the crp_id' do 
      filing = build(:loeb_filing_one)
      filing_found = @matcher.corresponding_os_donation(filing)
      expect(filing_found).to eq(@donation_one)
    end

    it 'finds the donation if the fec_filing_id is the microfilm number' do 
      filing = build(:loeb_filing_two)
      filing_found = @matcher.corresponding_os_donation(filing)
      expect(filing_found).to eq(@donation_two)
    end
    
  end

  describe '#match_all' do 
    
    it 'finds the fec_filing and calls match_one for each filing' do 
      matcher = OsLegacyMatcher.new 555
      expect(matcher).to receive(:match_one).twice
      allow(FecFiling).to receive(:where) { [@donation_one, @donation_two] }
      matcher.match_all
    end
    
  end


  describe '#match_one' do 

    it 'calls no_donation if no donation is found' do 
      matcher = OsLegacyMatcher.new 555
      expect(matcher).to receive(:no_donation).with(@filing_one)
      expect(matcher).to receive(:corresponding_os_donation).and_return(nil)
      matcher.match_one @filing_one
    end

    it 'calls create_os_match if a donation is returned' do
      matcher = OsLegacyMatcher.new 555
      expect(matcher).to receive(:corresponding_os_donation).and_return(@donation_one)
      expect(matcher).to receive(:create_os_match).with(@donation_one)
      matcher.match_one @filing_one
    end
  end

  describe '#find_reference' do

    
    
  end

  describe '#create_os_match' do

    before(:all) do 
      @matcher.create_os_match @donation_one
      @os_match = OsMatch.last
    end
    
    it 'creates new os_match' do 
      expect(@os_match).to be
    end

    it 'has relationship association' do 
      expect(@os_match.relationship).to eq @relationship
    end
    
    it 'has os_donation association' do 
      expect(@os_match.os_donation).to eq @donation_one
    end

    it 'has donor association' do 
      expect(@os_match.donor).to eq @loeb
    end

    it 'has recipient association' do 
      expect(@os_match.recipient).to eq @nrsc
    end

    it 'has reference association' do 
      expect(@os_match.reference).to eq @ref_one
    end

    it 'has donation assoication' do
      expect(@os_match.donation).to be_a(Donation)
      expect(@os_match.donation.relationship_id).to eq @relationship.id
    end
    
  end

end
