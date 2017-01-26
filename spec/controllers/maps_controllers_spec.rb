require 'rails_helper'

describe MapsController, type: :controller do
  before(:all) do
    [:set_defaults, :generate_index_data, :generate_secret].each { |x| NetworkMap.skip_callback(:save, :before, x) }
    DatabaseCleaner.start
  end
  after(:all) do
    [:set_defaults, :generate_index_data, :generate_secret].each { |x| NetworkMap.set_callback(:save, :before, x) }
    DatabaseCleaner.clean
  end

  describe 'routes' do
    it { should route(:get, '/maps/1706-colorado-s-terrible-ten').to(action: :show, id: '1706-colorado-s-terrible-ten') }
    it { should route(:get, '/maps/1706-colorado-s-terrible-ten/raw').to(action: :raw, id: '1706-colorado-s-terrible-ten') }
    it { should route(:post, '/maps/1706-colorado-s-terrible-ten/clone').to(action: :clone, id: '1706-colorado-s-terrible-ten') }
  end

  describe '#show' do
    def get_request
      expect(NetworkMap).to receive(:find).with("10-a-map").and_return(@map)
      get :show, {id: '10-a-map' }
    end

    it 'has two links if cloneable' do
      @map = build(:network_map, is_private: false, title: 'a map', is_cloneable: true)
      get_request
      expect(assigns(:links).length).to eql 2
    end

    it 'has one link if not cloneable' do
      @map = build(:network_map, is_private: false, title: 'a map', is_cloneable: false)
      get_request
      expect(assigns(:links).length).to eql 1
    end

    context 'GET with slug ' do
      before do
        @map = build(:network_map, is_private: false, title: 'a map')
        get_request
      end

      it { should respond_with :success }
      it { should render_template 'story_map' }

      it 'does not set dev_version' do
        expect(assigns(:dev_version)).to be_nil
      end
    end

    context 'private map - anon user' do
      before do
        @map = build(:network_map, is_private: true, title: 'a map')
        get_request
      end
      it { should respond_with 403 }
    end

    it 'redirects if no slug is provided' do
      @map = build(:network_map, is_private: false, title: 'a map')
      expect(NetworkMap).to receive(:find).with('10').and_return(@map)
      get :show, id: '10'
      expect(response.status).to eql 302
    end
  end

  describe '#dev' do
    login_user

    before do
      @map = build(:network_map, is_private: false, title: 'a map')
      expect(NetworkMap).to receive(:find).with('10-a-map').and_return(@map)
      expect(controller).to receive(:check_permission).with('admin')
      get :dev, id: '10-a-map'
    end

    it { should respond_with :success }
    it { should render_template 'story_map' }

    it 'sets dev_version' do
      expect(assigns(:dev_version)).to eql true
    end
  end

  describe '#raw' do
    before do
      @map = build(:network_map, title: 'a map')
      expect(NetworkMap).to receive(:find).with("10-a-map").and_return(@map)
      get :raw, {id: '10-a-map' }
    end
    it { should redirect_to(embedded_map_path(@map)) }
  end

  describe '#clone' do
    login_user
    
    context 'cloneable map' do
      before do
        @map_count = NetworkMap.count
        @map = build(:network_map, graph_data: '{}', user_id: 10000)
        expect(NetworkMap).to receive(:find).with('10-a-map').and_return(@map)
        post :clone, { id: '10-a-map' }
      end
      
      it 'creates a new map' do
        expect(NetworkMap.count).to eql(@map_count + 1)
      end
      
      it 'changes the user id' do
        expect(NetworkMap.last.user_id).to be_a(Integer)
        expect(NetworkMap.last.user_id).not_to eql 10000
      end
      
      it { should redirect_to(edit_map_path(NetworkMap.last)) }
    end
    
    context 'uncloneable map' do
      before do
        @map = build(:network_map, graph_data: '{}', is_cloneable: false)
        expect(NetworkMap).to receive(:find).with('10-a-map').and_return(@map)
        post :clone, { id: '10-a-map' }
      end

      it { should respond_with :unauthorized }
    end

  end
end
