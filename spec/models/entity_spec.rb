require 'rails_helper'

describe Entity do
  describe 'summary_excerpt' do 
    it 'returns nil if there is no summary' do
      mega_corp = build(:mega_corp_inc, summary: nil)
      expect(mega_corp.summary_excerpt).to be_nil
    end
    
    it 'truncates to under 100 chars' do
      mega_corp = build(:mega_corp_inc, summary: 'word ' * 50)
      expect(mega_corp.summary_excerpt.length).to be < 100
    end

    it 'returns just the first  paragraph even if the paragraph is less than 100 chars' do
      summary = ('x ' * 25) + "\n" + ('word ' * 25)
      mega_corp = build(:mega_corp_inc, summary: summary)
      expect(mega_corp.summary_excerpt.length).to eql(53)
      expect(mega_corp.summary_excerpt).to eql(('x ' * 25) + '...')
    end
  end
  
  describe 'Political' do 

    describe 'sqlize_array' do 
      it 'stringifies an array for a sql query' do 
        expect(Entity.sqlize_array ['123', '456', '789']).to eql("('123','456','789')")
      end
    end

    describe '#potential_contributions' do
      before(:all) do
        DatabaseCleaner.start
        Entity.skip_callback(:create, :after, :create_primary_ext)
        @loeb = create(:loeb)
        @nrsc = create(:nrsc)
        @loeb_donation = create(:loeb_donation) # relationship model
        @loeb_os_donation = create(:loeb_donation_one)
        @loeb_ref_one = create(:loeb_ref_one, object_id: @loeb_donation.id, object_model: "Relationship")
        @donation_class = create(:donation, relationship_id: @loeb_donation.id)
        @os_match = OsMatch.create(
          os_donation_id: @loeb_os_donation.id,
          donation_id: @donation_class.id,
          donor_id: @loeb.id,
          recip_id: @nrsc.id,
          reference_id: @loeb_ref_one.id,
          relationship_id: @loeb_donation.id)
      end
      after(:all) do
        Entity.set_callback(:create, :after, :create_primary_ext)
        DatabaseCleaner.clean
      end

      it 'retrieves matched contributions'
    
    end

  end
end
