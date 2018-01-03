require 'rails_helper'

describe UsersController, type: :controller do
  before(:all) { DatabaseCleaner.start }
  after(:all) { DatabaseCleaner.clean }

  describe 'routes' do
    it { should route(:get, '/users/admin').to(action: :admin) }
    it { should route(:get, '/users/a_username').to(action: :show, username: 'a_username') }
    it { should route(:get, '/users/a_username/edits').to(action: :edits, username: 'a_username') }
    it { should route(:get, '/users/123/edit_permissions').to(action: :edit_permissions, id: '123') }
    it { should route(:get, '/users/123/image').to(action: :image, id: '123') }
    it { should route(:post, '/users/123/restrict').to(action: :restrict, id: '123') }
    it { should route(:post, '/users/123/upload_image').to(action: :upload_image, id: '123') }
    it { should route(:delete, '/users/123/delete_permission').to(action: :delete_permission, id: '123') }
    it { should route(:delete, '/users/123/destroy').to(action: :destroy, id: '123') }
  end

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
    context 'as a regular user' do
      login_user
      before { get :admin }
      it { should respond_with(403) }
    end
  end

  describe 'GET #edit_permissions' do
    context 'as an admin' do
      login_admin
      before do
        expect(User).to receive(:find).with('1').and_return(build(:user))
        get :edit_permissions, params: { :id => '1' }
      end
      it { should render_template 'edit_permissions' }
    end
  end

  describe 'POST #add_permission' do
    login_admin
    before do
      expect(User).to receive(:find).with('1')
                        .and_return(build(:user, sf_guard_user_id: 2, id: 1))
      expect(SfGuardUserPermission).to receive(:create!).with(permission_id: 5, user_id: 2)
      post :add_permission, params: { :id => '1', :permission => '5' }
    end
    it { should redirect_to(edit_permissions_user_path) }
  end

  describe 'DELETE #delete_permission' do
    login_admin
    before do
      expect(User).to receive(:find).with('1')
                        .and_return(build(:user, sf_guard_user_id: 2, id: 1))
      expect(SfGuardUserPermission).to receive(:remove_permission).with(permission_id: 5, user_id: 2)
      delete :delete_permission, params: { :id => '1', :permission => '5' }
    end
    it { should redirect_to(edit_permissions_user_path) }
  end

  describe 'DELETE #destory' do
    describe 'logged in as admin' do
      login_admin

      context 'Deleting a user' do
        before(:each) do
          @sf_user = create(:sf_guard_user, is_deleted: false, username: "user#{rand(1000)}")
          @user = create(:user, sf_guard_user_id: @sf_user.id, email: "user#{rand(1000)}@email.com" , username: "user#{rand(1000)}")
          SfGuardUserPermission.create!(permission_id: 3, user_id: @sf_user.id)
          @entity = create(:mega_corp_inc, last_user_id: @sf_user.id)
        end

        it 'deletes permissions' do
          expect { delete :destroy, params: { :id => @user.id } }
            .to change { SfGuardUserPermission.count }.by(-1)
        end

        it 'marks sf_guard_user as deleted' do
          expect(SfGuardUser.unscoped.find(@sf_user.id).is_deleted).to be false
          delete :destroy, params: { :id => @user.id }
          expect(SfGuardUser.find_by_id(@sf_user.id)).to be_nil
          expect(SfGuardUser.unscoped.find(@sf_user.id).is_deleted).to be true
        end

        it 'updates last_user_id on entities' do
          expect(Entity.find(@entity.id).last_user_id).to eql @sf_user.id
          delete :destroy, params: { :id => @user.id }
          expect(Entity.find(@entity.id).last_user_id).to eql 1
        end

        it 'updates last_user_id on relationships' do
          expect(Relationship).to receive(:where).with(last_user_id: @sf_user.id).and_return(double(:update_all => nil))
          delete :destroy, params: { :id => @user.id }
        end

        it 'destroys user' do
          expect { delete :destroy, params: { :id => @user.id } }
            .to change { User.count }.by(-1)
        end

        context 'afterwards' do
          before { delete :destroy, params: { :id => @user.id } }
          it { should redirect_to(admin_users_path) }
        end
      end

      context 'Trying to delete an admin' do
        before do
          @sf_user = create(:sf_guard_user, is_deleted: false, username: "user#{rand(1000)}")
          @user = create(:user, sf_guard_user_id: @sf_user.id, email: "user#{rand(1000)}@email.com" , username: "user#{rand(1000)}")
          SfGuardUserPermission.create!(permission_id: 1, user_id: @sf_user.id)
        end

        it 'does not delete user' do
          expect { delete :destroy, params: { :id => @user.id } }
            .not_to change { User.count }
        end

        context 'afterwards' do
          before { delete :destroy, params: { :id => @user.id } }
          it { should redirect_to(admin_users_path) }
        end
      end
    end
  end

  describe '#success' do
    before { get :success }
    it { should respond_with(200) }
    it { should render_template('success') }
  end
end
