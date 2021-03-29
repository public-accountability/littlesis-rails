describe MapsController, type: :controller do
  describe 'routes' do
    it { is_expected.to route(:get, '/maps/1706-colorado-s-terrible-ten').to(action: :show, id: '1706-colorado-s-terrible-ten') }
    it { is_expected.to route(:get, '/maps/1706-colorado-s-terrible-ten/raw').to(action: :raw, id: '1706-colorado-s-terrible-ten') }
    it { is_expected.to route(:post, '/maps/1706-colorado-s-terrible-ten/clone').to(action: :clone, id: '1706-colorado-s-terrible-ten') }
    it { is_expected.to route(:delete, '/maps/1706-colorado-s-terrible-ten').to(action: :destroy, id: '1706-colorado-s-terrible-ten') }
    it { is_expected.to route(:get, '/maps/1706-colorado-s-terrible-ten/embedded').to(action: :embedded, id: '1706-colorado-s-terrible-ten') }
    it { is_expected.to route(:get, '/maps/1706-colorado-s-terrible-ten/embedded/v2').to(action: :embedded_v2, id: '1706-colorado-s-terrible-ten') }
    it { is_expected.to route(:get, '/maps/1706-colorado-s-terrible-ten/edit').to(action: :edit, id: '1706-colorado-s-terrible-ten') }
    it { is_expected.to route(:get, '/maps/featured').to(action: :featured) }
    it { is_expected.to route(:get, '/maps/all').to(action: :all) }
    it { is_expected.to route(:get, '/maps/search').to(action: :search) }
    it { is_expected.to route(:get, '/maps/find_nodes').to(action: :find_nodes) }
    it { is_expected.to route(:get, '/maps/node_with_edges').to(action: :node_with_edges) }
    it { is_expected.to route(:get, '/maps/edges_with_nodes').to(action: :edges_with_nodes) }
    it { is_expected.to route(:get, '/maps/interlocks').to(action: :interlocks) }
    it { is_expected.to route(:get, '/users/example_user/maps').to(action: :user, username: 'example_user') }
  end

  describe '#raw' do
    let(:map) { build(:network_map, title: 'a map') }

    before do
      allow(controller).to receive(:user_signed_in?).and_return(true)
      allow(NetworkMap).to receive(:find).once.with("10-a-map").and_return(map)
      get :raw, params: { id: '10-a-map' }
    end

    it { is_expected.to redirect_to(embedded_map_path(map)) }
  end

  describe '#clone' do
    login_user

    context 'when map if cloneable' do
      let(:map) { build(:network_map, user_id: 10_000) }
      let(:post_request) { -> { post :clone, params: { id: '10-a-map' } } }

      before do
        allow(NetworkMap).to receive(:find).with('10-a-map').once.and_return(map)
      end

      it 'creates a new map' do
        expect(&post_request).to change(NetworkMap, :count).by(1)
      end

      it 'changes the user id' do
        post_request.call
        expect(NetworkMap.last.user_id).to eql controller.current_user.id
      end

      it 'sets the clonned map to be private' do
        post_request.call
        expect(NetworkMap.last.is_private).to be true
      end

      it 'redirects to edit map path' do
        post_request.call
        expect(response).to redirect_to(edit_map_path(NetworkMap.last))
      end

      it 'appends "clone" to the oligrapher title' do
        post_request.call
        expect(NetworkMap.last.title).to eql 'Clone: so many connections'
      end
    end

    context 'when cloning a featured map' do
      let(:map) { build(:network_map, user_id: 10_000, is_featured: true) }

      before do
        allow(NetworkMap).to receive(:find).once.with('10-a-map').and_return(map)
        post :clone, params: { id: '10-a-map' }
      end

      it 'sets is_featured to be false' do
        expect(NetworkMap.last.is_featured).to be false
      end
    end

    context 'when map is not cloneable' do
      before do
        map = build(:network_map, graph_data: '{}', is_cloneable: false)
        allow(NetworkMap).to receive(:find).with('10-a-map').and_return(map)
        post :clone, params: { id: '10-a-map' }
      end

      it { is_expected.to respond_with :unauthorized }
    end
  end

  describe '#destroy' do
    before do
      allow(controller).to receive(:user_signed_in?).and_return(true)
    end

    it 'redirects after destroy'do
      map = build(:network_map, graph_data: '{}', is_cloneable: false)
      expect(NetworkMap).to receive(:find).with('10-a-map').and_return(map)
      expect(controller).to receive(:authenticate_user!)
      expect(controller).to receive(:check_owner)
      expect(map).to receive(:destroy)
      delete :destroy, params: { id: '10-a-map' }
      expect(response.status).to eq 302
      expect(response.location[-5..-1]).to eq maps_path
    end
  end

  describe '#embedded_v2' do
    let(:map) { build(:network_map, title: 'a map') }

    before do
      allow(controller).to receive(:user_signed_in?).and_return(true)
      allow(NetworkMap).to receive(:find).once.with("10-a-map").and_return(map)
    end

    it 'uses first slide by default' do
      get :embedded_v2, params: { id: '10-a-map' }
      expect(assigns(:configuration)[:startAnnotation]).to eq 0
    end

    it 'converts slide param 3 to starting index 2' do
      get :embedded_v2, params: { id: '10-a-map', slide: 3 }
      expect(assigns(:configuration)[:startAnnotation]).to eq 2
    end
  end
end
