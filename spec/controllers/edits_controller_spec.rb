require 'rails_helper'

describe EditsController, type: :controller do
  it { should route(:get, '/edits').to(action: :index) }

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
end
