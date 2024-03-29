describe OligrapherController, type: :controller do
  it do
    is_expected.to route(:get, '/oligrapher/find_nodes').to(action: :find_nodes)
  end

  it do
    is_expected.to route(:get, '/oligrapher/find_connections').to(action: :find_connections)
  end

  it do
    is_expected.to route(:get, '/oligrapher/get_edges').to(action: :get_edges)
  end

  it do
    is_expected.to route(:post, '/oligrapher').to(action: :create)
  end

  it do
    is_expected.to route(:patch, '/oligrapher/789').to(action: :update, id: '789')
  end

  it do
    is_expected.to route(:get, '/oligrapher/789-abc').to(action: :show, id: '789-abc')
  end

  it do
    is_expected.to route(:get, '/oligrapher/789-abc/screenshot').to(action: :screenshot, id: '789-abc')
  end

  it do
    is_expected.to route(:post, '/oligrapher/789-abc/editors').to(action: :editors, id: '789-abc')
  end

  it do
    is_expected.to route(:get, '/oligrapher/789-abc/lock').to(action: :lock, id: '789-abc')
  end

  it do
    is_expected.to route(:post, '/oligrapher/789-abc/lock').to(action: :lock, id: '789-abc')
  end

  it do
    is_expected.to route(:post, '/oligrapher/789-abc/clone').to(action: :clone, id: '789-abc')
  end

  it do
    is_expected.to route(:delete, '/oligrapher/789-abc').to(action: :destroy, id: '789-abc')
  end

  it do
    is_expected.to route(:delete, '/oligrapher/789/admin_destroy').to(action: :admin_destroy, id: '789')
  end


  it do
    is_expected.to route(:post, '/oligrapher/789-abc/confirm_editor').to(action: :confirm_editor, id: '789-abc')
  end

  it do
    is_expected.to route(:get, '/oligrapher/789/share/abc').to(action: :show, id: '789', secret: 'abc')
  end

  it do
    is_expected.to route(:get, '/oligrapher/get_interlocks').to(action: :get_interlocks)
  end

  it do
    is_expected.to route(:get, '/oligrapher/789/embedded').to(action: :embedded, id: '789')
  end

  it do
    is_expected.to route(:post, '/oligrapher/789-abc/release_lock').to(action: :release_lock, id: '789-abc')
  end

  it 'removes X-Frame-Options from embedded oligrapher request' do
    map = build_stubbed(:network_map_version3)
    expect(NetworkMap).to receive(:find).with(map.id.to_s).and_return(map)
    get :embedded, params: { id: map.id }
    expect(response.headers['X-Frame-Options']).to be nil
  end
end
