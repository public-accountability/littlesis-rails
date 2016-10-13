require 'rails_helper'

describe NysController, type: :controller do

  before(:all) do 
    Entity.skip_callback(:create, :after, :create_primary_ext)
    DatabaseCleaner.start
  end
  
  after(:all) do 
    Entity.set_callback(:create, :after, :create_primary_ext)
    DatabaseCleaner.clean
  end


  describe '#potential_contributions' do
    login_user
    
    it 'returns 200' do 
      person = build(:person, id: 12345, name: "big donor")
      disclosure = double('NyDisclosure')
      expect(disclosure).to receive(:map)
      expect(Entity).to receive(:find).with(12345).and_return(person)
      expect(NyDisclosure).to receive(:search)
                               .with('big donor', :with=>{:is_matched=>false}, :sql=>{:include=>:ny_filer}  )
                               .and_return(disclosure)
      get(:potential_contributions, entity: '12345')
      expect(response.status).to eq(200)
    end
    
  end

  describe '#match_donations' do 
    login_user
    
    it 'Matches provides ids' do 
      expect(NyMatch).to receive(:match).with('12', '666', kind_of(Numeric))
      expect(NyMatch).to receive(:match).with('17', '666', kind_of(Numeric))
      post(:match_donations, {payload: {disclosure_ids: [12, 17], donor_id: '666'}})
    end

    it 'creates new matches' do 
      person = create(:person, name: "big donor")
      disclosure = create(:ny_disclosure)
      count = NyMatch.count
      post(:match_donations, {payload: {disclosure_ids: [disclosure.id ], donor_id: person.id}})
      
      expect(NyMatch.count).to eql (count + 1)
    end

  end

end
