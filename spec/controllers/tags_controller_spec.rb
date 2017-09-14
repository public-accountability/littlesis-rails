require 'rails_helper'

describe TagsController, type: :controller do
  it { should route(:get, '/tags/456').to(action: :show, id: 456) }
  it { should route(:get, '/tags').to(action: :index) }
  it { should route(:get, '/tags/456/edit').to(action: :edit, id: 456) }
  it { should route(:post, '/tags').to(action: :create) }
  it { should route(:put, '/tags/456').to(action: :update, id: 456) }
  it { should route(:delete, '/tags/456').to(action: :destroy, id: 456) }
  it { should route(:get, '/tags/456/entities').to(action: :show, id: 456, tagable_category: 'entities') }
  it { should route(:get, '/tags/request').to(action: :tag_request) }
  it { should route(:post, '/tags/request').to(action: :tag_request) }
end
