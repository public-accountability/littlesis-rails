describe UsersController, type: :controller do
  describe 'routes' do
    it { is_expected.not_to route(:get, '/users').to(action: :index) }
    it { is_expected.to route(:get, '/users/admin').to(action: :admin) }
    it { is_expected.to route(:get, '/users/a_username').to(action: :show, username: 'a_username') }
    it { is_expected.to route(:get, '/users/a_username/edits').to(action: :edits, username: 'a_username') }
    it { is_expected.to route(:get, '/users/123/edit_permissions').to(action: :edit_permissions, id: '123') }
    # it { is_expected.to route(:get, '/users/123/image').to(action: :image, id: '123') }
    it { is_expected.to route(:post, '/users/check_username').to(action: :check_username) }
    it { is_expected.to route(:post, '/users/123/restrict').to(action: :restrict, id: '123') }
    # it { is_expected.to route(:post, '/users/123/upload_image').to(action: :upload_image, id: '123') }
    it { is_expected.to route(:delete, '/users/123/delete_permission').to(action: :delete_permission, id: '123') }
    it { is_expected.to route(:delete, '/users/123/destroy').to(action: :destroy, id: '123') }
  end

  describe 'GET #admin' do
    context 'as an admin' do
      login_admin
      before { get :admin }

      it { is_expected.to render_template('admin') }
    end

    context 'as a regular user' do
      login_user
      before { get :admin }

      it { is_expected.to respond_with(403) }
    end
  end

  describe 'DELETE #destory' do
    describe 'logged in as admin' do
      login_admin

      describe 'Deleting a user' do
        let(:user) { create_basic_user }
        let(:entity) { create(:entity_org, last_user_id: user.id) }

        before { entity }

        it 'updates last_user_id on entities' do
          expect(Entity.find(entity.id).last_user_id).to eql user.id
          delete :destroy, params: { :id => user.id }
          expect(Entity.find(entity.id).last_user_id).to eq 1
        end

        it 'updates last_user_id on relationships' do
          expect(Relationship).to receive(:where).with(last_user_id: user.id)
                                    .and_return(double(:update_all => nil))

          delete :destroy, params: { :id => user.id }
        end

        it 'destroys user' do
          expect { delete :destroy, params: { :id => user.id } }.to change(User, :count).by(-1)
        end

        describe 'afterwards' do
          before { delete :destroy, params: { :id => user.id } }

          it { is_expected.to redirect_to(admin_users_path) }
        end
      end

      context 'When trying to delete an admin' do
        let(:user) { create_admin_user }

        before { user }

        it 'does not delete user' do
          expect { delete :destroy, params: { :id => user.id } }.not_to change(User, :count)
        end

        describe 'afterwards' do
          before { delete :destroy, params: { :id => user.id } }

          it { is_expected.to redirect_to(admin_users_path) }
        end
      end
    end
  end

  describe '#success' do
    before { get :success }

    it { is_expected.to respond_with(200) }
    it { is_expected.to render_template('success') }
  end
end
