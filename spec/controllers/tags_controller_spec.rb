require 'rails_helper'

describe TagsController, type: :controller do
  it { should route(:get, '/tags/456/edit').to(action: :edit, id: 456) }
  it { should route(:post, '/tags').to(action: :create) }
  it { should route(:put, '/tags/456').to(action: :update, id: 456) }
  it { should route(:delete, '/tags/456').to(action: :destroy, id: 456) }
end
