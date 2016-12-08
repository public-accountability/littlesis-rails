require 'rails_helper'

describe RelationshipsController, type: :controller do

  before(:all) do 
    Entity.skip_callback(:create, :after, :create_primary_ext)
    DatabaseCleaner.start
  end
  
  after(:all) do 
    Entity.set_callback(:create, :after, :create_primary_ext)
    DatabaseCleaner.clean
  end
  
  it { should route(:get, "/relationships/1").to(action: :show, id: 1) }
  it { should route(:post, "/relationships").to(action: :create) } 

  describe "GET #show" do

    before do
      @rel = build(:relationship)
      expect(Relationship).to receive(:find).with("1").and_return(@rel)
      get :show, {id: 1}
    end
    
    it { should respond_with(:success) } 
    it { should render_template(:show) }
    
    it 'assigns relationship' do
      expect(assigns(:relationship)).to eql @rel
    end

  end

  describe 'POST #create' do
    let(:e1) { create(:person)  }
    let(:e2) { create(:mega_corp_inc) } 

    def example_params(entity1_id="10", entity2_id="20")
      {
        relationship: {
	  entity1_id: entity1_id,
	  entity2_id: entity2_id,
	  category_id: "1"
        },
        reference: {
	  name: "Interesting website",
          source_detail: "",
	  source: "http://example.com",
	  publication_date: "2016-01-01",
	  ref_type: "1"
        }
      }
    end
    
    context 'with valid params' do
      
      def post_request
        post :create, example_params(e1.id, e2.id)
      end

      it 'responds with 201' do
        post_request
        expect(response.status).to eq 201
      end
      
      it 'should create a new relationship' do
        expect { post_request }.to change{Relationship.count}.by(1)
      end

      it 'should create a new Reference' do
        expect { post_request }.to change{Reference.count}.by(1)
      end
      
      it 'should create reference with correct fields' do 
        post_request
        r = Reference.last
        expect(r.name).to eql "Interesting website"
        expect(r.ref_type).to eql 1
        expect(r.object_model).to eql "Relationship"
        expect(r.object_id). to eql Relationship.last.id
      end
    end

    context 'with invalid params' do

      
      it 'responds with 400 if missing category_id' do 
        post :create, example_params.tap { |x| x[:relationship].delete(:category_id) } 
        expect(response.status).to eq 400
      end

      it 'sends error json with bad relationship params' do 
        post :create, example_params.tap { |x| x[:relationship].delete(:category_id) } 
        expect(JSON.parse(response.body)).to have_key "relationship"
        expect(JSON.parse(response.body)).to have_key "reference"
        expect(JSON.parse(response.body)['relationship']).to have_key 'category_id'
      end

      it 'responds with 400 if reference source' do 
        post :create, example_params.tap { |x| x[:reference].delete(:source) } 
        expect(response.status).to eq 400
      end

      it 'sends error json with reference params' do 
        post :create, example_params.tap { |x| x[:reference].delete(:source) } 
        expect(JSON.parse(response.body)).to have_key "relationship"
        expect(JSON.parse(response.body)).to have_key "reference"
        expect(JSON.parse(response.body)['reference']). to have_key 'source'
        expect(JSON.parse(response.body)['relationship']).not_to have_key 'category_id'
      end

      it 'sends error json with reference & relationship params' do 
        post :create, example_params.tap { |x| x[:reference].delete(:source) }.tap { |x| x[:relationship].delete(:category_id) }
        expect(JSON.parse(response.body)['reference']).to have_key 'source'
        expect(JSON.parse(response.body)['relationship']).to have_key 'category_id'
      end
      
    end
    

    describe 'params' do 
      
      before do 
        r = build(:generic_relationship)
        allow(r).to receive(:save!)
        allow(Relationship).to receive(:new).and_return(r)
      end 
        
      it do
        should permit(:entity1_id, :entity2_id, :category_id)
                .for(:create, params: example_params).on(:relationship)
      end

      it do
        should permit(:name, :source, :source_detail, :publication_date, :ref_type)
                .for(:create, params: example_params).on(:reference)
      end
    end
    
  end # end describe POST #create
end
