require 'rails_helper'

describe UsersController, type: :controller do

  describe 'GET #index' do
    login_admin
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
  
  describe 'GET #edit_permissions' do 
    context 'as an admin' do 
      login_admin
      before do 
        expect(User).to receive(:find).with('1')
        get :edit_permissions, :id => '1' 
      end
      it { should render_template 'edit_permissions' }
    end
  end

  describe 'POST #add_permission' do 
    login_admin
    before do 
      expect(User).to receive(:find).with('1').and_return(double(:sf_guard_user_id => 2, :id => 1))
      expect(SfGuardUserPermission).to receive(:create!).with(permission_id: 5, user_id: 2)
      post :add_permission, :id => '1', :permission => '5'
    end
    it { should redirect_to(edit_permissions_user_path) }
  end

  describe 'DELETE #delete_permission' do 
    login_admin
    before do 
      expect(User).to receive(:find).with('1').and_return(double(:sf_guard_user_id => 2, :id => 1))
      expect(SfGuardUserPermission).to receive(:remove_permission).with(permission_id: 5, user_id: 2)
      delete :delete_permission, :id => '1', :permission => '5'
    end
    it { should redirect_to(edit_permissions_user_path) }
  end


  
end
