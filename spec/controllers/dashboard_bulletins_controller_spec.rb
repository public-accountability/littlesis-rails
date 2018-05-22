require 'rails_helper'

describe DashboardBulletinsController, type: :controller do
  it { is_expected.to route(:get, '/dashboard_bulletins/new').to(action: :new) }
  it { is_expected.to route(:post, '/dashboard_bulletins').to(action: :create) }
  it do
    is_expected.to route(:get, '/dashboard_bulletins/123/edit')
                     .to(action: :edit, id: '123')
  end
  it do
    is_expected.to route(:patch, '/dashboard_bulletins/123')
                     .to(action: :update, id: '123')
  end
end
