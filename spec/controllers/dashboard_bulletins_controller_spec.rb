require 'rails_helper'

describe DashboardBulletinsController, type: :controller do
  it { is_expected.to route(:get, '/dashboard_bulletins/new').to(action: :new) }
end
