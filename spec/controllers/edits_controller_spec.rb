require 'rails_helper'

describe EditsController, type: :controller do
  it { should route(:get, '/edits').to(action: :index) }
  it { should route(:get, '/entities/123/edits').to(action: :entity, id: 123) }

  describe 'GET :index' do
    login_user 
    
    before do
      expect(Entity).to receive(:includes)
                         .and_return(double(order: double(page: double(per: []))))
      get :index
    end
    it { should respond_with 200 }
    it { should render_template 'index'  }
  end

  describe 'GET :entity' do
    login_user

    before do
      expect(Entity).to receive(:find).and_return(build(:person))
      get :entity, id: '123'
    end
    it { should respond_with 200 }
    it { should render_template 'entity' }
  end
end
