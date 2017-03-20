require 'rails_helper'

describe ListsController, type: :controller do
  before(:each) { DatabaseCleaner.start }
  after(:each) { DatabaseCleaner.clean }

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
        expect(Reference.last.object_model).to eql 'List'
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
end
