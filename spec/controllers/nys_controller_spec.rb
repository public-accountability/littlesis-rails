require 'rails_helper'

describe NysController, type: :controller do

  before(:all) do 
    Entity.skip_callback(:create, :after, :create_primary_ext)
    ActiveJob::Base.queue_adapter = :test
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
      expect(person).to receive(:aliases).and_return( [double(:name => 'Big Donor')] )
      disclosure = double('NyDisclosure')
      expect(disclosure).to receive(:map)
      expect(Entity).to receive(:find).with(12345).and_return(person)
      expect(NyDisclosure).to receive(:search)
                               .with('Big Donor', :with=>{:is_matched=>false, :transaction_code=>["'A'", "'B'", "'C'"]}, :sql=>{:include=>:ny_filer}, :per_page => 500)
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

    describe 'thinking sphinx:' do 
      before(:all) do
        @disclosure = create(:ny_disclosure)
      end

      it 'Updates delta on ny disclosure' do 
        allow(NyMatch).to receive(:match)
        expect(NyDisclosure).to receive(:update_delta_flag).with(['12', '17'])
        post(:match_donations, {payload: {disclosure_ids: [12, 17], donor_id: '666'}})
      end

      # it 'enques delayed_delta job' do 
      #   allow(NyMatch).to receive(:match)
      #   expect { post(:match_donations, {payload: {disclosure_ids: [@disclosure.id], donor_id: '666'}}) }
      #     .to have_enqueued_job.on_queue('delta')
      # end

    end

    it 'clears legacy cache of donor' do 
      allow(NyMatch).to receive(:match)
      entity_mock = instance_double('Entity', :touch => nil)
      expect(Entity).to receive(:find).with('666') { entity_mock }
      delay_mock = double('delay')
      expect(entity_mock).to receive(:delay) { delay_mock }
      expect(delay_mock).to receive(:clear_legacy_cache).with('test.host')
      post(:match_donations, {payload: {disclosure_ids: [12, 17], donor_id: '666'}})
    end

    it 'creates new matches' do 
      person = create(:person, name: "big donor")
      
      disclosure = create(:ny_disclosure)
      count = NyMatch.count
      post(:match_donations, {payload: {disclosure_ids: [disclosure.id ], donor_id: person.id}})
      
      expect(NyMatch.count).to eql (count + 1)
    end

    it 'changes updated_at field' do
      person = create(:person, name: "big donor")
      person.update_column(:updated_at, 1.day.ago)
      allow(NyMatch).to receive(:match)
      post(:match_donations, payload: { disclosure_ids: [1], donor_id: person.id })
      expect(Entity.find(person.id).updated_at > person.updated_at).to be true
    end
  end

  describe "#create" do
    login_user
    before do 
      ny_filer = build(:ny_filer, filer_id: "C9")
      expect(NyFilerEntity).to receive(:create!).with(entity_id: '123', ny_filer_id:  '10', filer_id: 'C9')
      expect(NyFilerEntity).to receive(:create!).with(entity_id: '123', ny_filer_id:  '11', filer_id: 'C9')
      expect(NyFiler).to receive(:find).with('10').and_return(ny_filer)
      expect(NyFiler).to receive(:find).with('11').and_return(ny_filer)
      entity = double('entity')
      expect(entity).to receive(:update).with(hash_including(:last_user_id => controller.current_user.sf_guard_user.id))
      expect(Entity).to receive(:find).with('123').and_return(entity)
    end

    it 'Handles POST'  do 
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
