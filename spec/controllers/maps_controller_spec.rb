require 'rails_helper'

describe MapsController do
  it { is_expected.to route(:get, '/maps/find_nodes').to(action: :find_nodes) }
  it { is_expected.to route(:get, '/maps/node_with_edges').to(action: :node_with_edges) }
  it { is_expected.to route(:get, '/maps/edges_with_nodes').to(action: :edges_with_nodes) }
  it { is_expected.to route(:get, '/maps/interlocks').to(action: :interlocks) }
end
