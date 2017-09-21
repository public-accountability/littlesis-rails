require 'rails_helper'

describe TagsController, type: :controller do
  it { should route(:get, '/tags/456').to(action: :show, id: 456) }
  it { should route(:get, '/tags').to(action: :index) }
  it { should route(:get, '/tags/456/edit').to(action: :edit, id: 456) }
  it { should route(:post, '/tags').to(action: :create) }
  it { should route(:put, '/tags/456').to(action: :update, id: 456) }
  it { should route(:delete, '/tags/456').to(action: :destroy, id: 456) }
  it { should route(:get, '/tags/request').to(action: :tag_request) }
  it { should route(:post, '/tags/request').to(action: :tag_request) }

  it { should route(:get, 'tags/456/edits').to(action: :edits, id: 456) }

  Tagable.categories.each do |tagable_category|
    it do
      should(route(:get, "/tags/456/#{tagable_category}")
              .to(action: :show, id: 456, tagable_category: tagable_category))
    end
  end
  it do
    should(route(:get, "tags/456/not_a_tagable_category")
            .to(controller: :errors, action: :not_found, path: "tags/456/not_a_tagable_category"))
  end
end
