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
    is_expected.to route(:get, '/oligrapher/example').to(action: :example)
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
    is_expected.to route(:get, '/oligrapher/789-abc/editors').to(action: :get_editors, id: '789-abc')
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
    is_expected.to route(:post, '/oligrapher/789-abc/confirm_editor').to(action: :confirm_editor, id: '789-abc')
  end

  it do
    is_expected.to route(:get, '/oligrapher/789/share/abc').to(action: :show, id: '789', secret: 'abc')
  end

  it do
    is_expected.to route(:get, '/oligrapher/get_interlocks').to(action: :get_interlocks)
  end
end