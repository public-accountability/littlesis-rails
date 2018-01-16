require 'rails_helper'

describe AdminController, type: :controller do
  it { is_expected.to route(:get, '/admin').to(action: :home) }
  it { is_expected.to route(:get, '/admin/tags').to(action: :tags) }
  it { is_expected.to route(:get, '/admin/stats').to(action: :stats) }
end
