require 'rails_helper'

describe AdminController, type: :controller do
  it { should route(:get, '/admin').to(action: :home) }
  it { should route(:get, '/admin/tags').to(action: :tags) }
end
