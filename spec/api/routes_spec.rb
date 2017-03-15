require 'rails_helper'

describe 'API ROUTES' do
  describe Api::ApiController, type: :controller do
    it { should route(:get, '/api').to(action: :index) }
  end

  describe Api::EntitiesController, type: :controller do
    it { should route(:get, '/api/entities/123').to(action: :show, id: '123') }
    it { should route(:get, '/api/entities/123/relationships').to(action: :relationships, id: '123') }
    it { should route(:get, '/api/entities/123/extensions').to(action: :extensions, id: '123') }
    # it { should route(:get, '/api/entities/123/extensions/business').to(action: :extensions, id: '123') }
  end
end
