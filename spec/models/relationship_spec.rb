require 'rails_helper'

describe Relationship, type: :model do
  before(:all) do
    DatabaseCleaner.start
    Entity.skip_callback(:create, :after, :create_primary_ext)
    @loeb = create(:loeb)
    @nrsc = create(:nrsc)
    @loeb_donation = create(:loeb_donation, filings: 1, amount: 10000) # relationship model        
  end
  after(:all) do 
    Entity.set_callback(:create, :after, :create_primary_ext)
    DatabaseCleaner.clean
  end

  describe 'associations' do 
    it { should have_many(:links) }
    it { should belong_to(:entity) }
    it { should belong_to(:related) }
    it { should have_one(:position) }
    it { should have_one(:education) }
    it { should have_one(:membership) }
    it { should have_one(:family) }
    it { should have_one(:trans) }
    it { should have_one(:ownership) }
    it { should belong_to(:category) }
    it { should belong_to(:last_user) }
    it { should have_many(:os_matches) }
    it { should have_many(:os_donations) }
    it { should have_many(:ny_matches) }
    it { should have_many(:ny_disclosures) }
  end

  describe 'validations' do
    it { should validate_presence_of(:entity1_id) }
    it { should validate_presence_of(:entity2_id) }
    it { should validate_presence_of(:category_id) }
    it { should validate_length_of(:start_date).is_at_most(10) }
    it { should validate_length_of(:end_date).is_at_most(10) }

    describe 'Date Validation' do
      def rel(attr)
        build(:relationship, {category_id: 12, entity1_id: 123, entity2_id: 456}.merge(attr) )
      end
      it 'accepts good dates' do
        expect(rel(start_date: '2000-00-00').valid?).to be true
        expect(rel(end_date: '2000-10-00').valid?).to be true
        expect(rel(end_date: '2017-01-20').valid?).to be true
        expect(rel(start_date: nil).valid?).to be true
      end

      it 'does not accept bad dates' do
        expect(rel(start_date: '2000-13-00').valid?).to be false
        expect(rel(end_date: '2000-10').valid?).to be false
        expect(rel(end_date: '2017').valid?).to be false
        expect(rel(start_date: '').valid?).to be false
      end

    end
  end

  describe 'create_category' do
    it 'creates associated category model' do
      rel = build(:position_relationship)
      expect(Position).to receive(:create).with(relationship: rel).once
      rel.create_category
    end
  end

  describe 'create_links' do
    it 'creates 2 links after creating relationship' do
      e1 = create(:person)
      e2 = create(:person)
      expect { Relationship.create!(category_id: 12, entity: e1, related: e2) }.to change { Link.count }.by(2)
    end
  end

  describe 'category_name' do
    it 'returns correct names' do
      expect(build(:position_relationship).category_name).to eql "Position"
      expect(build(:generic_relationship).category_name).to eql "Generic"
    end
  end


  describe '#title' do 
    it 'returns description1 if it exists' do 
      rel = build(:position_relationship, description1: "dictator")
      expect(rel.title).to eql 'dictator'
    end

    it 'returns Board Member if the person is a board member' do 
       rel = create(:relationship, entity1_id: @loeb.id, entity2_id: @nrsc.id, category_id: 1)
       rel.position.update(is_board: true)
       expect(rel.title).to eql 'Board Member'
    end
    
    it 'returns "Member" if the position is a membership category' do 
      rel = create(:relationship, entity1_id: @loeb.id, entity2_id: @nrsc.id, category_id: 3)
      expect(rel.title).to eql 'Member'
    end

    it 'returns degree if Education description1 is blank and there is a degree id' do 
      rel = create(:relationship, entity1_id: @loeb.id, entity2_id: @nrsc.id, category_id: 2)
      rel.education.update(degree_id: 2)
      expect(rel.title).to eql 'Bachelor of Arts'
    end
    
  end


  describe 'Update Start/End dates' do 
    describe '#date_string_to_date' do 
      it 'returns nil if no date' do
        r = build(:loeb_donation, start_date: nil)
        expect(r.date_string_to_date(:start_date)).to be_nil
      end

      it 'returns nil if bad year' do
        r = build(:loeb_donation, start_date: "badd-00-00")
        expect(r.date_string_to_date(:start_date)).to be_nil
      end
      
      it 'converts "2012-00-00"' do 
        r = build(:loeb_donation)
        expect(r.date_string_to_date(:start_date)).to eq Date.new(2010)
      end

      it 'converts "2012-12-00"' do 
        r = build(:loeb_donation, start_date: "2012-12-00")
        expect(r.date_string_to_date(:start_date)).to eq Date.new(2012, 12)
      end

      it 'converts "2012-04-10"' do 
        r = build(:loeb_donation, start_date: "2012-4-10")
        expect(r.date_string_to_date(:start_date)).to eq Date.new(2012, 4, 10)
      end
    end
  end

  describe '#update_start_date_if_earlier' do
    it 'updates start date' do
      @loeb_donation.update_start_date_if_earlier Date.new(1999)
      expect(@loeb_donation.start_date).to eql('1999-01-01')
    end

    it 'updates end date' do
      @loeb_donation.update_end_date_if_later Date.new(2012)
      expect(@loeb_donation.end_date).to eql('2012-01-01')
    end

    it 'does not change if not earlier' do
      @loeb_donation.update_start_date_if_earlier Date.new(2010)
      expect(@loeb_donation.start_date).to eql('1999-01-01')
    end

    it 'does not change if not later' do
      @loeb_donation.update_end_date_if_later Date.new(2010)
      expect(@loeb_donation.end_date).to eql('2012-01-01')
    end

    it 'can handle nil input' do
      @loeb_donation.update_start_date_if_earlier nil
      expect(@loeb_donation.start_date).to eql('1999-01-01')
      @loeb_donation.update_end_date_if_later nil
      expect(@loeb_donation.end_date).to eql('2012-01-01')
    end
  end

  describe '#update_contribution_info' do
    before(:all) do
      d1 = create(:loeb_donation_one)
      d2 = create(:loeb_donation_two)
      OsMatch.create!(relationship_id: @loeb_donation.id, os_donation_id: d1.id, donor_id: @loeb.id)
      OsMatch.create!(relationship_id: @loeb_donation.id, os_donation_id: d2.id, donor_id: @loeb.id)
      @loeb_donation.update_os_donation_info
    end
    
    it 'updates amount' do
      expect(@loeb_donation.amount).to eql 80800
    end

    it 'updates filing' do
      expect(@loeb_donation.filings).to eql 2
    end

    it 'does not update the database' do
      expect(Relationship.find(@loeb_donation.id).amount).not_to eql 80800
    end

    it 'can be chained with .save' do 
      @loeb_donation.update_os_donation_info.save
      expect(Relationship.find(@loeb_donation.id).amount).to eql 80800
    end

  end
  
  describe '#update_ny_contribution_info' do
    before(:all) do
      donor = create(:person, name: 'I <3 ny politicans')
      elected = create(:elected)
      @rel = Relationship.create(entity1_id: donor.id, entity2_id: elected.id, category_id: 5)
      disclosure1 = create(:ny_disclosure, amount1: 2000)
      disclosure2 = create(:ny_disclosure, amount1: 3000)
      match1 = create(:ny_match, ny_disclosure_id: disclosure1.id, donor_id: donor.id, recip_id: elected.id, relationship: @rel)
      match1 = create(:ny_match, ny_disclosure_id: disclosure2.id, donor_id: donor.id, recip_id: elected.id, relationship: @rel)
      @rel.update_ny_donation_info
    end
    
    it 'updates amount' do
      expect(@rel.amount).to eql 5000
    end

    it 'Sets description if blank' do 
      expect(@rel.description1).to eql "NYS Campaign Contribution"
    end

    it 'updates filing' do
      expect(@rel.filings).to eql 2
    end

    it 'does not update the database' do
      expect(Relationship.find(@rel.id).attributes.slice('amount', 'filings')).to eql({"amount" => nil, "filings" => nil})
    end

    it 'can be chained with .save to update the db' do 
      @rel.update_ny_donation_info.save
      expect(Relationship.find(@rel.id).attributes.slice('amount', 'filings')).to eql({"amount" => 5000, "filings" => 2})
    end

  end


  describe '#name' do
    it 'generates correct title for position relationship' do 
      rel = build(:relationship, category_id: 1, description1: 'boss')
      rel.position = build(:position, is_board: false)
      expect(rel.name).to eql "Position: Human Being, mega corp LLC"
    end
  end

  describe 'legacy_url' do 
    before(:all) do 
      @rel = build(:relationship, id: 1000)
    end
    
    it 'generates correct url' do 
      expect(@rel.legacy_url).to eql "/relationship/view/id/1000" 
    end
    
    it 'generates correct url with action' do 
      expect(@rel.legacy_url('edit')).to eql "/relationship/edit/id/1000" 
    end
  end

  describe '#details' do 
    describe 'it returns [ [field, value] ] for each Relationship type' do 
      it 'Position' do 
        rel = build(:relationship, category_id: 1, description1: 'boss', is_current: true)
        rel.position = build(:position, is_board: false)
        expect(rel.details).to eql [['Title', 'boss'], ['Is Current', 'yes'], ['Board member', 'no']]
      end
    end
  end
  describe 'reverse_direction' do
    before do
      @human = create(:person)
      @corp = create(:corp)
      @rel = Relationship.create!(entity1_id: @human.id, entity2_id: @corp.id, category_id: 12)
    end

    it 'changes the direction of relationship' do
      expect(@rel.entity1_id).to eql @human.id
      expect(@rel.entity2_id).to eql @corp.id
      @rel.reverse_direction
      expect(Relationship.find(@rel.id).entity2_id).to eql @human.id
      expect(Relationship.find(@rel.id).entity1_id).to eql @corp.id
    end
    it 'reverses links' do
      expect(Link.where(entity1_id: @human.id, relationship_id: @rel.id)[0].is_reverse).to be false
      expect(Link.where(entity2_id: @human.id, relationship_id: @rel.id)[0].is_reverse).to be true
      @rel.reverse_direction
      expect(Link.where(entity1_id: @human.id, relationship_id: @rel.id)[0].is_reverse).to be true
      expect(Link.where(entity2_id: @human.id, relationship_id: @rel.id)[0].is_reverse).to be false
    end
  end

  describe 'position_or_membership_type' do
    before do
      @human_1 = create(:person)
      @human_2 = create(:person)
      @corp = create(:corp)
      @elected = create(:elected)
      @us_house = create(:us_house)
    end

    it 'returns "None" for a relationship that is not a position or a membership' do
      rel = Relationship.create!(entity1_id: @human_1.id, entity2_id: @corp.id, category_id: 4)
      expect(rel.position_or_membership_type).to eql 'None'
    end

    it 'correctly identifies a business position' do
      rel = Relationship.create!(entity1_id: @human_1.id, entity2_id: @corp.id, category_id: 1)
      rel.related.stub(:extension_names).and_return ['Org', 'Business']
      expect(rel.position_or_membership_type).to eql 'Business'
    end

    it 'correctly identifies a government position' do
      rel = Relationship.create!(entity1_id: @human_1.id, entity2_id: @us_house.id, category_id: 1)
      rel.related.stub(:extension_names).and_return ['Org', 'GovernmentBody']
      expect(rel.position_or_membership_type).to eql 'Government'
    end

    it 'correctly identifies an "in the office of" position' do
      rel = Relationship.create!(entity1_id: @human_1.id, entity2_id: @elected.id, category_id: 1, start_date: "2012-01-02", end_date: "2016-03-04")
      rel.related.stub(:extension_names).and_return ['Person', 'ElectedRepresentative']
      expect(rel.position_or_membership_type).to eql 'In The Office Of'
    end

    it 'categorizes all other positions as "Other"' do
      rel = Relationship.create!(entity1_id: @human_1.id, entity2_id: @human_2.id, category_id: 1)
      expect(rel.position_or_membership_type).to eql 'Other Positions & Memberships'
    end
  end

  describe '#display_date_range' do
    it 'returns (past)' do
      rel = build(:relationship, start_date: nil, end_date: nil, is_current: false)
      expect(rel.display_date_range).to eq '(past)'
    end

    it 'returns plain date if dates are equal' do
      rel = build(:relationship, start_date: '1999-00-00', end_date: '1999-00-00')
      expect(rel.display_date_range).to eq "('99)"
    end
  end

  context 'Using paper_trail for versioning' do
    with_versioning do
      before do
        @human = create(:person)
        @corp = create(:corp)
      end
      it 'records created, modified, and deleted versions' do
        rel = Relationship.create!(entity1_id: @human.id, entity2_id: @corp.id, category_id: 12)
        expect(rel.versions.size).to eq(1)
        rel.description1 = "important connection"
        rel.save
        expect(rel.versions.size).to eq(2)
        expect(rel.versions.last.event).to eq('update')
        rel.destroy
        expect(rel.versions.size).to eq(3)
        expect(rel.versions.last.event).to eq('destroy')
      end
    end
  end

end
