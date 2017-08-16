require 'rails_helper'

describe ListsController, :list_helper, type: :controller do
  before(:all) { DatabaseCleaner.start }
  after(:all) { DatabaseCleaner.clean }

  describe 'GET /lists' do
    login_user

    before do
      new_list = create(:list)
      new_list2 = create(:list, name: 'my interesting list')
      new_list3 = create(:list, name: 'someone else private list', is_private: true, creator_user_id: controller.current_user.id + 1)
      new_list4 = create(:list, name: 'current user private list', is_private: true, creator_user_id: controller.current_user.id)
      @inc = create(:mega_corp_inc)
      ListEntity.find_or_create_by(list_id: new_list.id, entity_id: @inc.id)
      ListEntity.find_or_create_by(list_id: new_list2.id, entity_id: @inc.id)
      ListEntity.find_or_create_by(list_id: new_list3.id, entity_id: @inc.id)
      ListEntity.find_or_create_by(list_id: new_list4.id, entity_id: @inc.id)
      get :index
    end

    it { should respond_with(:success) }
    it { should render_template(:index) }

    it '@lists only includes public lists and private lists created by the current user' do
      expect(assigns(:lists).length).to eq(3)
    end

    it '@lists has correct names' do
      expect(assigns(:lists)[0].name).to eq("Fortune 1000 Companies")
      expect(assigns(:lists)[1].name).to eq("my interesting list")
      expect(assigns(:lists)[2].name).to eq("current user private list")
    end

    it '@lists does not include private list created by some other user' do
      list_names = assigns(:lists).map { |list| list.name }
      expect(list_names).not_to include('someone else private list')
    end
  end

  describe 'user not logged in' do
    before do
      @new_list = create(:list, name: 'my interesting list', is_private: false, creator_user_id: 123)
      @private_list = create(:list, name: 'someone else private list', is_private: true, creator_user_id: 123)
      @inc = create(:mega_corp_inc)
      ListEntity.find_or_create_by(list_id: @new_list.id, entity_id: @inc.id)
      ListEntity.find_or_create_by(list_id: @private_list.id, entity_id: @inc.id)
      get :index
    end

    it { should render_template(:index) }

    it '@lists only includes public lists' do
      expect(assigns(:lists).length).to eq 1
      expect(assigns(:lists)[0]).to eq @new_list
    end
  end

  describe 'POST create' do
    login_user

    context 'When missing name and source' do
      before do
        post :create, list: { name: '' }, ref: {}
      end

      it 'renders new template' do
        expect(response).to render_template(:new)
      end

      it 'has two errors' do
        expect(assigns(:list).errors.size).to eq(2)
      end
    end

    context 'When missing just name or just source' do
      it 'renders new template' do
        post :create, list: { name: 'a name' }, ref: {}
        expect(response).to render_template(:new)
      end

      it 'has one error - blank name' do
        post :create, list: { name: '' }, ref: { source: 'http://mysource' }
        expect(assigns(:list).errors.size).to eq 1
      end

      it 'has one error - missing source' do
        post :create, list: { name: 'the list name' }, ref: {}
        expect(assigns(:list).errors.size).to eq 1
      end
    end

    context 'When has both name and source' do
      it 'redirects to the newly created list' do
        post :create,  list: {name: 'list name'}, ref: { source: 'http://mysource' }
        expect(response).to redirect_to(assigns(:list))
      end

      it 'saves the list' do
        expect do
          post :create, list: { name: 'list name' }, ref: { source: 'http://mysource' }
        end.to change { List.count }.by(1)
        expect(List.last).to eql assigns(:list)
      end

      it 'create a reference with a name provided' do
        expect do
          post :create, list: { name: 'list name' }, ref: { source: 'http://mysource' }
        end.to change { Reference.count }.by(1)

        expect(Reference.last.object_id).to eql assigns(:list).id
        expect(Reference.last.object_model).to eql 'LsList'
        # the reference name is set to be the same as the the source url if no name isprovided
        expect(Reference.last.name).to eql 'http://mysource'
        expect(Reference.last.source).to eql 'http://mysource'
      end

      it 'creates a reference with a name provided' do
        post(:create, list: { name: 'list name' }, ref: { source: 'http://mysource', name: 'important source' })
        expect(Reference.last.name).to eql('important source')
        expect(Reference.last.source).to eql('http://mysource')
      end
    end

    describe 'modifications' do
      before(:each) do 
        @new_list = create(:list)
        get(:modifications, {id: @new_list.id})
      end

      it 'renders modifications template' do 
        expect(response).to render_template(:modifications)
      end

      it 'has @versions' do 
        expect(assigns(:versions)).to eq(@new_list.versions)
      end
    end
  end

  describe 'show' do
    before { get :show, id: 1 }
    it { should respond_with(302) }
    it { should redirect_to(action: :members) }
  end

  describe 'edit' do
    login_user

    it 'calls check_permission when list is admin' do
      expect(List).to receive(:find).and_return(build(:list, is_admin: true))
      expect(controller).to receive(:check_permission).with('admin')
      get :edit, id: 1
    end

    it 'calls check_permission when list is network' do
      expect(List).to receive(:find).and_return(build(:list, is_network: true))
      expect(controller).to receive(:check_permission).with('admin')
      get :edit, id: 1
    end

    it 'does not call check_permission if list is not admin or network' do
      expect(List).to receive(:find).and_return(build(:list))
      expect(controller).not_to receive(:check_permission).with('admin')
      get :edit, id: 1
    end

    describe 'request' do
      before do
        expect(List).to receive(:find).and_return(build(:list))
        get :edit, id: 1
      end
      it { should render_template :edit }
      it { should respond_with :success }
    end
  end

  describe 'remove_entity' do
    login_admin
    before(:all) do
      @list = create(:list)
      @list.update_column(:updated_at, 1.day.ago)
      @person = create(:person)
      @list_entity = ListEntity.create!(list_id: @list.id, entity_id: @person.id)
    end

    before do
      @post_remove_entity = proc { post :remove_entity, { id: @list.id, list_entity_id: @list_entity.id } }
    end

    it 'removes the list entity' do
      expect(&@post_remove_entity).to change { ListEntity.unscoped.find(@list_entity.id).is_deleted}.to(true)
    end
    
    it 'clears the list cache' do
      expect(List).to receive(:find).with(@list.id.to_s).and_return(@list)
      expect(@list).to receive(:clear_cache)
      @post_remove_entity.call
    end

    it 'updates the updated_at of the list' do
      expect(&@post_remove_entity).to change {
        List.find(@list.id).updated_at
      }
    end

    it 'redirects to the members page' do
      @post_remove_entity.call
      expect(response).to have_http_status(302)
    end
  end

  describe 'GET members' do
    before(:all) do
      @creator = create_basic_user
      @non_creator = create_really_basic_user
      @lister = create_basic_user
      @admin = create_admin_user
      @open_list = build(:open_list, creator_user_id: @creator.id)
      @closed_list = build(:closed_list, creator_user_id: @creator.id)
      @private_list = build(:private_list, creator_user_id: @creator.id)
    end

    context 'open list' do
      before do
        allow(ListDatatable).to receive(:new).and_return(spy('table'))
        @request.env["devise.mapping"] = Devise.mappings[:user]
        expect(List).to receive(:find).and_return(@open_list)
      end

      [
        {
          user: nil,
          action: :members,
          response: :success
        },
        {
          user: '@creator',
          action: :members,
          response: :success
        },
        {
          user: '@non_creator',
          action: :members,
          response: :success
        },
        {
          user: '@lister',
          action: :members,
          response: :success
        },
        {
          user: '@admin',
          action: :members,
          response: :success
        }
      ].each { |x| test_request_for_user(x) }
    end

    context 'private list' do
      before do
        allow(ListDatatable).to receive(:new).and_return(spy('table'))
        @request.env["devise.mapping"] = Devise.mappings[:user]
        expect(List).to receive(:find).and_return(@private_list)
      end

      [
        {
          user: nil,
          action: :members,
          response: 403
        },
        {
          user: '@creator',
          action: :members,
          response: :success
        },
        {
          user: '@non_creator',
          action: :members,
          response: 403
        },
        {
          user: '@lister',
          action: :members,
          response: 403
        },
        {
          user: '@admin',
          action: :members,
          response: :success
        }
      ].each { |x| test_request_for_user(x) }
    end

    context 'closed list' do
      before do
        allow(ListDatatable).to receive(:new).and_return(spy('table'))
        @request.env["devise.mapping"] = Devise.mappings[:user]
        expect(List).to receive(:find).and_return(@closed_list)
      end

      [
        {
          user: nil,
          action: :members,
          response: :success
        },
        {
          user: '@creator',
          action: :members,
          response: :success
        },
        {
          user: '@non_creator',
          action: :members,
          response: :success
        },
        {
          user: '@lister',
          action: :members,
          response: :success
        },
        {
          user: '@admin',
          action: :members,
          response: :success
        }
      ].each { |x| test_request_for_user(x) }
    end
  end

  describe "#set_permisions" do
    before do
      @controller = ListsController.new
      @user = create_basic_user
      @list = build(:list, access: List::ACCESS_OPEN, creator_user_id: @user.id)
      @controller.instance_variable_set(:@list, @list)
    end

    it "sets permissions for a logged-in user" do
      allow(@controller).to receive(:current_user).and_return(@user)
      expect(@user.permissions).to receive(:list_permissions).with(@list)
      @controller.send(:set_permissions)
    end

    it "sets permissions for an anonymous user" do
      allow(@controller).to receive(:current_user).and_return(nil)
      expect(UserPermissions::Permissions).to receive(:anon_list_permissions).with(@list)
      @controller.send(:set_permissions)
    end
  end
end
