require 'rails_helper'

describe EntitiesController, type: :controller do

  before(:each) { DatabaseCleaner.start }
  after(:each)  { DatabaseCleaner.clean }

  describe 'routes' do
    it { should route(:get, '/entities/1').to(action: :show, id: 1) }
    it { should route(:get, '/entities/1/relationships').to(action: :relationships, id: 1) }
    it { should route(:get, '/entities/new').to(action: :new) } 
    it { should route(:post, '/entities').to(action: :create) } 
  end


  describe 'GET' do 
    before { @entity = create(:mega_corp_inc, updated_at: Time.now) }

    describe "/entity/id" do
      before { get(:show, {id: @entity.id}) } 

      it { should render_template(:show) }

      it 'sets the entity var' do 
        expect(assigns(:entity).id).to eql @entity.id
      end
      
    end

    describe 'entity/id/relationships' do 
      before { get(:relationships, {id: @entity.id}) } 
      it { should render_template(:relationships) }
    end

  end

  describe '#create' do
    login_user
    let(:params) { {"entity"=>{"name"=>"new entity", "blurb"=>"a blurb goes here", "primary_ext"=>"Org" }} }
    let(:params_missing_ext) { {"entity"=>{"name"=>"new entity", "blurb"=>"a blurb goes here", "primary_ext"=>"" }} }
    let(:params_add_relationship_page) { params.merge({'add_relationship_page' => 'TRUE'}) }
    let(:params_missing_ext_add_relationship_page) { params_missing_ext.merge({'add_relationship_page' => 'TRUE'}) }
    
    context 'from the /entities/new page' do
      context 'without errors' do 
        
        it 'redirects to edit url' do
          post :create, params
          expect(response).to redirect_to(Entity.last.legacy_url('edit'))
        end

        it 'should create a new entity' do
          expect{ post :create, params }.to change{Entity.count}.by(1)
        end

      end 

      context 'with errors' do
        
        it 'Renders new entities page' do
          post :create, params_missing_ext
          expect(response).to render_template(:new)
        end

        it 'sould NOT create a new entity' do
          expect{ post :create, params_missing_ext }.not_to change{Entity.count}
        end
      end
    end
    
    context 'from the /entiites/id/add_relationship page' do
      context 'without errors' do
        it 'should create a new entity' do
          expect{ post :create, params_add_relationship_page }.to change{Entity.count}.by(1)
        end

        it 'should render json with entity id' do
          post :create, params_add_relationship_page
          expect(response.body).to eql({entity_id: Entity.last.id, status: 'OK'}.to_json)
        end
      end

      context 'with errors' do
        it 'should NOT create a new entity' do
          expect{ post :create, params_missing_ext_add_relationship_page }.not_to change{Entity.count}
        end

        it 'should render json with errors' do
          post :create, params_missing_ext_add_relationship_page
          expect(JSON.parse(response.body)).to have_key 'errors'
          expect(JSON.parse(response.body).fetch 'status').to eql 'ERROR'
        end
      end
    end
  end


  describe 'Political' do 
    before { @entity = create(:mega_corp_inc, updated_at: Time.now) } 

    describe 'Political' do 
      before { get(:political, {id: @entity.id}) } 
      it { should render_template(:political) }
    end

    describe 'GET #match_donations' do
      login_user
      before do
         expect(Entity).to receive(:find).once   
         get(:match_donations, {id: rand(100) })
      end
      it { should render_template(:match_donations) }
      it { should use_before_action(:authenticate_user!) }
      it { should use_before_action(:set_entity) }       
    end

    describe 'match/unmatch donations' do 
      login_user

      before(:all) do 
        @entity = create(:mega_corp_inc)
      end

      describe 'POST #match_donation' do
        
        before(:each) do
          d1 = create(:os_donation, fec_cycle_id: 'unique_id_1')
          d2 = create(:os_donation, fec_cycle_id: 'unique_id_2')
          post :match_donation, {id: @entity.id, payload: [d1.id, d2.id]}
        end
        
        it { should respond_with(200) }     

        it "updates the entity's last user id after matching" do 
          expect(@entity.reload.last_user_id).to eql SfGuardUser.last.id
        end

        it 'sets the matched_by field of OsMatch' do 
          OsMatch.last(2).each do |match|
            expect(match.matched_by).to eql User.last.id
            expect(match.user).to eql User.last
          end
        end

        describe 'Clearing Cache' do
          
          def setup
            allow(OsMatch).to receive(:find_or_create_by!) { double('osmatch').as_null_object }
            mock_entity = instance_double('Entity')
            mock_delay = double('delay')
            expect(mock_delay).to receive(:clear_legacy_cache)
            expect(mock_entity).to receive(:delay) { mock_delay }
            expect(mock_entity).to receive(:update)
            expect(Entity).to receive(:find).with('7').and_return(mock_entity)
          end

          before { OsMatch.skip_callback :create, :after, :post_process }
          after { OsMatch.set_callback :create, :after, :post_process }
          
          it 'deletes legacy cache on match' do
            setup
            post :match_donation, {id: 7, payload: [1]}
          end
        end
      end
      
      describe 'POST #unmatch_donation'do 
        before do 
          @os_match = double('os match')
          expect(@os_match).to receive(:destroy).exactly(3).times
          expect(OsMatch).to receive(:find).exactly(3).times.and_return(@os_match)
          post :unmatch_donation, {id: @entity.id, payload: [5,6,7]}
        end
        
        it { should respond_with(200) }
        
      end

      describe 'GET /match_ny_donations' do
        before { get(:match_ny_donations, {id: @entity.id}) } 
        it { should respond_with(200) }
        it { should render_template(:match_ny_donations) }
      end  
    end

    describe 'GET #add_relationship' do 
      login_user
      before do
        expect(Entity).to receive(:find)
        get :add_relationship, {id: rand(100) }
      end
      it { should render_template(:add_relationship) }
      it { should respond_with(200) }
    end
    
  end
end
