describe MapsController, type: :controller do
  describe 'routes' do
    it { is_expected.to route(:get, '/maps/1706-colorado-s-terrible-ten').to(action: :show, id: '1706-colorado-s-terrible-ten') }
    it { is_expected.to route(:get, '/maps/1706-colorado-s-terrible-ten/raw').to(action: :raw, id: '1706-colorado-s-terrible-ten') }
    it { is_expected.to route(:get, '/maps/1706-colorado-s-terrible-ten/embedded').to(action: :embedded, id: '1706-colorado-s-terrible-ten') }
    it { is_expected.to route(:get, '/maps/1706-colorado-s-terrible-ten/embedded/v2').to(action: :embedded_v2, id: '1706-colorado-s-terrible-ten') }
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
end
