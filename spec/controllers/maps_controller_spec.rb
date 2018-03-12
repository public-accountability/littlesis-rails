require 'rails_helper'

describe MapsController do
  it { is_expected.to route(:get, '/maps/123-oligrapher').to(action: :show, id: '123-oligrapher') }
  it { is_expected.to route(:post, '/maps/123-oligrapher/feature').to(action: :feature, id: '123-oligrapher') }
  it { is_expected.to route(:get, '/maps/find_nodes').to(action: :find_nodes) }
  it { is_expected.to route(:get, '/maps/node_with_edges').to(action: :node_with_edges) }
  it { is_expected.to route(:get, '/maps/edges_with_nodes').to(action: :edges_with_nodes) }
  it { is_expected.to route(:get, '/maps/interlocks').to(action: :interlocks) }
  it { is_expected.to route(:get, '/maps/featured').to(action: :featured) }
  it { is_expected.to route(:get, '/maps/all').to(action: :all) }
end
