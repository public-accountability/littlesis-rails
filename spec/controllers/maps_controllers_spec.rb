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
    it { should route(:delete, '/maps/1706-colorado-s-terrible-ten').to(action: :destroy, id: '1706-colorado-s-terrible-ten') }
    it { should route(:get, '/maps/1706-colorado-s-terrible-ten/embedded').to(action: :embedded, id: '1706-colorado-s-terrible-ten') }
    it { should route(:get, '/maps/1706-colorado-s-terrible-ten/embedded/v2').to(action: :embedded_v2, id: '1706-colorado-s-terrible-ten') }
    it { should route(:get, '/maps/1706-colorado-s-terrible-ten/embedded/v2/dev').to(action: :embedded_v2_dev, id: '1706-colorado-s-terrible-ten') }
    it { should route(:get, '/maps/1706-colorado-s-terrible-ten/edit').to(action: :edit, id: '1706-colorado-s-terrible-ten') }
    it { should route(:get, '/maps/1706-colorado-s-terrible-ten/dev').to(action: :dev, id: '1706-colorado-s-terrible-ten') }
    it { should route(:get, '/maps/1706-colorado-s-terrible-ten/edit/dev').to(action: :dev_edit, id: '1706-colorado-s-terrible-ten') }
    it { should route(:get, '/maps/featured').to(action: :featured) }
    it { should route(:get, '/maps/search').to(action: :search) }
    it { should route(:get, '/maps/find_nodes').to(action: :find_nodes) }
    it { should route(:get, '/maps/node_with_edges').to(action: :node_with_edges) }
    it { should route(:get, '/maps/edges_with_nodes').to(action: :edges_with_nodes) }
    it { should route(:get, '/maps/interlocks').to(action: :interlocks) } 
  end

  describe '#show' do
    def get_request
      allow(controller).to receive(:user_signed_in?).and_return(true)
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

    describe 'Calls cache if user is anonymous' do
      before do
        @map = build(:network_map, title: 'a map')
        mock_cache = double('cache')
        expect(Rails).to receive(:cache).and_return(mock_cache)
        expect(mock_cache).to receive(:fetch).with('maps_controller/network_map/10-a-map', expires_in: 5.minutes).and_return(@map)
        get :show, id: '10-a-map'
      end

      it { should respond_with :success }
      it { should render_template 'story_map' }
      
      it 'sets cacheable to be true' do
        expect(assigns(:cacheable)).to eql true
      end
    end
    
    describe 'does not call cache when user is logged in' do
      login_user
      
      before do
        @map = build(:network_map, title: 'a map')
        expect(NetworkMap).to receive(:find).with('10-a-map').and_return(@map)
        expect(Rails).not_to receive(:cache)
        get :show, id: '10-a-map'
      end

      it { should respond_with :success }
      it { should render_template 'story_map' }
      
      it 'sets cacheable to be nil' do
        expect(assigns(:cacheable)).to be_nil
      end
    end

    it 'redirects if no slug is provided' do
      @map = build(:network_map, is_private: false, title: 'a map')
      allow(controller).to receive(:user_signed_in?).and_return(true)
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
      allow(controller).to receive(:user_signed_in?).and_return(true)
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

  describe '#destroy' do
    before do
      @map = build(:network_map, graph_data: '{}', is_cloneable: false)
      allow(controller).to receive(:user_signed_in?).and_return(true)
      expect(NetworkMap).to receive(:find).with('10-a-map').and_return(@map)
      expect(controller).to receive(:authenticate_user!)
      expect(controller).to receive(:check_owner)
      expect(controller).to receive(:check_permission).with('editor')
      expect(@map).to receive(:destroy)
      delete :destroy, { id: '10-a-map' }
    end

    it { should redirect_to(maps_path) }
  end

  describe '#embedded' do
    before do
      expect(NetworkMap).to receive(:find).with('10-a-map').and_return(build(:network_map))
      allow(controller).to receive(:user_signed_in?).and_return(true)
      get :embedded, { id: '10-a-map' }
    end

    it { should render_template('embedded') }
    it { should render_with_layout('fullscreen') }
  end
end
