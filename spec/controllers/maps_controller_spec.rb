require 'rails_helper'

describe MapsController do
  it { is_expected.to route(:get, '/maps/find_nodes').to(action: :find_nodes) }
end
