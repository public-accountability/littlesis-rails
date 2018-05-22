require 'rails_helper'

describe DashboardBulletinsController, type: :controller do
  it { is_expected.to route(:get, '/dashboard_bulletins/new').to(action: :new) }
  it { is_expected.to route(:post, '/dashboard_bulletins').to(action: :create) }
end
