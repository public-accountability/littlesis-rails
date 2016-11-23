require 'rails_helper'

describe AdminController, type: :controller do

  describe 'GET #show' do
    context 'as an admin' do 
      login_admin
      before { get :home }
      it { should render_template('home') }
    end
    context 'as an regular user' do 
      login_user
      before { get :home }
      it { should respond_with(403) }
    end
  end
  
end
