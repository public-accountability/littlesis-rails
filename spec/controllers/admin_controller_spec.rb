require 'rails_helper'

describe AdminController, type: :controller do
  it { should route(:get, '/admin').to(action: :home) }
  it { should route(:post, '/admin/clear_cache').to(action: :clear_cache) }
  it { should route(:get, '/admin/tags').to(action: :tags) }
end
