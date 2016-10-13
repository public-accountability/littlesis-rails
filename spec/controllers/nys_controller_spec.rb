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

  describe "#create" do 
    login_user

    it 'Handles POST'  do 
      ny_filer = build(:ny_filer, filer_id: "C9")
      expect(NyFilerEntity).to receive(:create!).with(entity_id: '123', ny_filer_id:  '10', filer_id: 'C9')
      expect(NyFilerEntity).to receive(:create!).with(entity_id: '123', ny_filer_id:  '11', filer_id: 'C9')
      expect(NyFiler).to receive(:find).with('10').and_return(ny_filer)
      expect(NyFiler).to receive(:find).with('11').and_return(ny_filer)
      post(:create, entity: '123', ids: ['10','11'] )
      expect(response.status).to eq(302)
    end
  end

  describe "#new_filer_entity" do 
    login_user

    before(:each) do 
      elected = build(:elected, id: 123)
      expect(elected).to receive(:person).and_return(double(:name_last => "elected"))
      expect(NyFiler).to receive(:search_filers).with("elected").and_return([])
      expect(Entity).to receive(:find).and_return(elected)
    end

    it 'Handles GET' do 
      get(:new_filer_entity, entity: '123')
      expect(response.status).to eq(200)
      expect(response).to render_template(:new_filer_entity)
    end

    
  end

end
