require 'rails_helper'

describe UsersController, type: :controller do

  describe 'GET #index' do
    login_user
    before { get :index } 
    it { should render_template('index') }
  end
  
  describe 'GET #admin' do
    context 'as an admin' do 
      login_admin
      before { get :admin }
      it { should render_template('admin') }
    end
    context 'as an regular user' do 
      login_user
      before { get :admin }
      it { should respond_with(403) }
    end
  end

  
end
