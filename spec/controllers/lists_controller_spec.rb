require 'rails_helper'

describe ListsController, :list_helper, type: :controller do
  before(:all) { DatabaseCleaner.start }
  after(:all) { DatabaseCleaner.clean }

  it { should route(:delete, '/lists/1').to(action: :destroy, id: 1) }
  it { should route(:post, '/lists/1/tags').to(action: :tags, id: 1) }
  it { should route(:get, '/lists/1/entities/bulk').to(action: :new_entity_associations, id: 1) }
  it { should route(:post, '/lists/1/entities/bulk').to(action: :create_entity_associations, id: 1) }

  describe 'GET /lists' do
    login_user
    before do
      new_list = create(:list)
      new_list2 = create(:list, name: 'my interesting list')
      new_list3 = create(:list, name: 'someone else private list', access: Permissions::ACCESS_PRIVATE, creator_user_id: controller.current_user.id + 1)
      new_list4 = create(:list, name: 'current user private list', access: Permissions::ACCESS_PRIVATE, creator_user_id: controller.current_user.id)
      @inc = create(:entity_org)
      ListEntity.find_or_create_by(list_id: new_list.id, entity_id: @inc.id)
      ListEntity.find_or_create_by(list_id: new_list2.id, entity_id: @inc.id)
      ListEntity.find_or_create_by(list_id: new_list3.id, entity_id: @inc.id)
      ListEntity.find_or_create_by(list_id: new_list4.id, entity_id: @inc.id)
      get :index
    end

    it { should respond_with(:success) }
    it { should render_template(:index) }

    xit '@lists only includes public lists and private lists created by the current user' do
      expect(assigns(:lists).length).to eq(3)
    end

    xit '@lists has correct names' do
      expect(assigns(:lists)[0].name).to eq("Fortune 1000 Companies")
      expect(assigns(:lists)[1].name).to eq("my interesting list")
      expect(assigns(:lists)[2].name).to eq("current user private list")
    end

    xit '@lists does not include private list created by some other user' do
      list_names = assigns(:lists).map { |list| list.name }
      expect(list_names).not_to include('someone else private list')
    end
  end

  describe 'user not logged in' do
    before do
      @new_list = create(:open_list, name: 'my interesting list', creator_user_id: 123)
      @private_list = create(:list, name: 'someone else private list', access: Permissions::ACCESS_PRIVATE, creator_user_id: nil)
      @inc = create(:entity_org)
      ListEntity.find_or_create_by(list_id: @new_list.id, entity_id: @inc.id)
      ListEntity.find_or_create_by(list_id: @private_list.id, entity_id: @inc.id)
      get :index
    end

    it { should render_template(:index) }

    xit '@lists only includes public lists' do
      expect(assigns(:lists).length).to eq 1
      expect(assigns(:lists)[0]).to eq @new_list
    end
  end

  describe 'POST create' do
    login_user

    context 'When missing name and url' do
      before { post :create, list: { name: '' }, ref: { url: '' } }
      specify { expect(response).to render_template(:new) }
      specify { expect(assigns(:list).errors.size).to eq(2) }
    end

    context 'When missing just name or just source' do
      it 'renders new template' do
        post :create, list: { name: 'a name' }, ref: { url: '' }
        expect(response).to render_template(:new)
      end

      it 'has one error - blank name' do
        post :create, list: { name: '' }, ref: { url: 'http://mysource' }
        expect(assigns(:list).errors.size).to eq 1
      end

      it 'has one error - missing source' do
        post :create, list: { name: 'the list name' }, ref: { url: '' }
        expect(assigns(:list).errors.size).to eq 1
      end
    end

    context 'submission with name and source' do
      it 'redirects to the newly created list' do
        post :create,  list: {name: 'list name'}, ref: { url: 'http://mysource' }
        expect(response).to redirect_to(assigns(:list))
      end

      it 'saves the list' do
        expect do
          post :create, list: { name: 'list name' }, ref: { url: 'http://mysource' }
        end.to change { List.count }.by(1)
        expect(List.last).to eql assigns(:list)
      end

      it 'create a reference with a name provided' do
        expect do
          post :create, list: { name: 'list name' }, ref: { url: 'http://mysource' }
        end.to change { Reference.count }.by(1)

        expect(Reference.last.referenceable_id).to eql assigns(:list).id
        expect(Reference.last.referenceable_type).to eql 'List'
        # the reference name is set to be the same as the the source url if no name isprovided
        expect(Reference.last.document.url).to eql 'http://mysource'
      end

      it 'creates a reference with a name provided' do
        post(:create, list: { name: 'list name' }, ref: { url: 'http://mysource', name: 'important source' })
        expect(Reference.last.document.name).to eql'important source'
        expect(Reference.last.document.url).to eql 'http://mysource'
      end
    end

    describe 'modifications' do
      before do
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
    before do
      expect(List).to receive(:find).and_return(build(:list))
      get :show, id: 1
    end
    it { should respond_with(302) }
    it { should redirect_to(action: :members) }
  end

  describe 'remove_entity' do
    login_admin
    let(:list) { create(:list).tap { |l| l.update_column(:updated_at, 1.day.ago) } }
    let(:person) { create(:entity_person) } 
    let(:list_entity) {  ListEntity.create!(list_id: list.id, entity_id: person.id) } 

    before do
      @post_remove_entity = proc { post :remove_entity, { id: list.id, list_entity_id: list_entity.id } }
    end

    it 'removes the list entity' do
      expect(&@post_remove_entity).to change { ListEntity.unscoped.find(list_entity.id).is_deleted}.to(true)
    end
    
    xit 'clears the list cache' do
      expect(List).to receive(:find).with(list.id.to_s).and_return(list)
      expect(list).to receive(:clear_cache)
      @post_remove_entity.call
    end

    it 'updates the updated_at of the list' do
      expect(&@post_remove_entity).to change {
        List.find(list.id).updated_at
      }
    end

    it 'redirects to the members page' do
      @post_remove_entity.call
      expect(response).to have_http_status(302)
    end
  end

  describe 'List access controls' do
    before(:all) do
      DatabaseCleaner.start
      @creator = create_basic_user
      @non_creator = create_really_basic_user
      @lister = create_basic_user
      @admin = create_admin_user
      @open_list = create(:open_list, creator_user_id: @creator.id)
      @closed_list = create(:closed_list, creator_user_id: @creator.id)
      @private_list = create(:private_list, creator_user_id: @creator.id)
    end

    after(:all) { DatabaseCleaner.clean }

    before do
      allow(controller).to receive(:interlocks_query)
      allow(controller).to receive(:interlocks_results)
    end

    context 'open list' do
      before do
        allow(ListDatatable).to receive(:new).and_return(spy('table'))
        allow(ListEntity).to receive(:find).and_return(spy('listentity'))
        allow(ListEntity).to receive(:find_or_create_by).and_return(spy('find_or_create_by'))
        @request.env["devise.mapping"] = Devise.mappings[:user]
        expect(List).to receive(:find).and_return(@open_list)
      end

      [
        # members action
        { user: nil, action: :members, response: :success },
        { user: '@creator', action: :members, response: :success },
        { user: '@non_creator', action: :members, response: :success },
        { user: '@lister', action: :members, response: :success },
        { user: '@admin', action: :members, response: :success },
        # interlocks action
        { user: nil, action: :interlocks, response: :success },
        { user: '@creator', action: :interlocks, response: :success },
        { user: '@non_creator', action: :interlocks, response: :success },
        { user: '@lister', action: :interlocks, response: :success },
        { user: '@admin', action: :interlocks, response: :success },
        # giving action
        { user: nil, action: :giving, response: :success },
        { user: '@creator', action: :giving, response: :success },
        { user: '@non_creator', action: :giving, response: :success },
        { user: '@lister', action: :giving, response: :success },
        { user: '@admin', action: :giving, response: :success },
        # funding action
        { user: nil, action: :funding, response: :success },
        { user: '@creator', action: :funding, response: :success },
        { user: '@non_creator', action: :funding, response: :success },
        { user: '@lister', action: :funding, response: :success },
        { user: '@admin', action: :funding, response: :success },
        # references action
        { user: nil, action: :references, response: :success },
        { user: '@creator', action: :references, response: :success },
        { user: '@non_creator', action: :references, response: :success },
        { user: '@lister', action: :references, response: :success },
        { user: '@admin', action: :references, response: :success },
        # edit action
        { user: nil, action: :edit, response: 403 },
        { user: '@creator', action: :edit, response: :success },
        { user: '@non_creator', action: :edit, response: 403 },
        { user: '@admin', action: :edit, response: :success },
        { user: '@lister', action: :edit, response: 403 },
        # update action
        { user: nil, action: :update, response: 403 },
        { user: '@creator', action: :update, response: 302 },
        { user: '@non_creator', action: :update, response: 403 },
        { user: '@admin', action: :update, response: 302 },
        { user: '@lister', action: :update, response: 403 },
        # destroy action
        { user: nil, action: :destroy, response: 403 },
        { user: '@creator', action: :destroy, response: 302 },
        { user: '@non_creator', action: :destroy, response: 403 },
        { user: '@admin', action: :destroy, response: 302 },
        { user: '@lister', action: :destroy, response: 403 },
        # add entity
        { user: nil, action: :add_entity, response: 403 },
        { user: '@creator', action: :add_entity, response: 302 },
        { user: '@non_creator', action: :add_entity, response: 403 },
        { user: '@admin', action: :add_entity, response: 302 },
        { user: '@lister', action: :add_entity, response: 302 },
        # remove entity
        { user: nil, action: :remove_entity, response: 403 },
        { user: '@creator', action: :remove_entity, response: 302 },
        { user: '@non_creator', action: :remove_entity, response: 403 },
        { user: '@admin', action: :remove_entity, response: 302 },
        { user: '@lister', action: :remove_entity, response: 302 },
        # new_entity associations action
        { user: nil, action: :new_entity_associations, response: 403 },
        { user: '@creator', action: :new_entity_associations, response: :success },
        { user: '@non_creator', action: :new_entity_associations, response: 403 },
        { user: '@admin', action: :new_entity_associations, response: :success },
        { user: '@lister', action: :new_entity_associations, response: :success },
        # create entity associations action
        # TODO: why do the commented-out specs generate the following error:
        # No route matches {:action=>"/associations/entities", :controller=>"lists"}
        # { user: nil, action: :create_entity_associations, response: 403 },
        # { user: '@creator', action: :create_entity_associations, response: 302 },
        # { user: '@non_creator', action: :create_entity_associations, response: 403 },
        # { user: '@admin', action: :create_entity_associations, response: 302 },
        # { user: '@lister', action: :create_entity_associations, response: 302 },
        # update entity
        # in #update_entity, 404 = successful call that falls thru
        { user: nil, action: :remove_entity, response: 403 },
        { user: '@creator', action: :update_entity, response: 404 },
        { user: '@non_creator', action: :update_entity, response: 403 },
        { user: '@admin', action: :update_entity, response: 404 },
        { user: '@lister', action: :update_entity, response: 404 }
      ].each { |x| test_request_for_user(x) }
    end

    context 'private list' do
      before do
        allow(ListDatatable).to receive(:new).and_return(spy('table'))
        allow(ListEntity).to receive(:find).and_return(spy('listentity'))
        allow(ListEntity).to receive(:find_or_create_by).and_return(spy('find_or_create_by'))
        @request.env["devise.mapping"] = Devise.mappings[:user]
        expect(List).to receive(:find).and_return(@private_list)
      end

      [
        # members action
        { user: nil, action: :members, response: 403 },
        { user: '@creator', action: :members, response: :success },
        { user: '@non_creator', action: :members, response: 403 },
        { user: '@lister', action: :members, response: 403 },
        { user: '@admin', action: :members, response: :success },
        # interlocks action
        { user: nil, action: :interlocks, response: 403 },
        { user: '@creator', action: :interlocks, response: :success },
        { user: '@non_creator', action: :interlocks, response: 403 },
        { user: '@lister', action: :interlocks, response: 403 },
        { user: '@admin', action: :interlocks, response: :success },
        # giving action
        { user: nil, action: :giving, response: 403 },
        { user: '@creator', action: :giving, response: :success },
        { user: '@non_creator', action: :giving, response: 403 },
        { user: '@lister', action: :giving, response: 403 },
        { user: '@admin', action: :giving, response: :success },
        # funding action
        { user: nil, action: :funding, response: 403 },
        { user: '@creator', action: :funding, response: :success },
        { user: '@non_creator', action: :funding, response: 403 },
        { user: '@lister', action: :funding, response: 403 },
        { user: '@admin', action: :giving, response: :success },
        # references action
        { user: nil, action: :references, response: 403 },
        { user: '@creator', action: :references, response: :success },
        { user: '@non_creator', action: :references, response: 403 },
        { user: '@lister', action: :references, response: 403 },
        { user: '@admin', action: :giving, response: :success },
        # update action
        { user: nil, action: :update, response: 403 },
        { user: '@creator', action: :update, response: 302 },
        { user: '@non_creator', action: :update, response: 403 },
        { user: '@admin', action: :update, response: 302 },
        { user: '@lister', action: :update,response: 403 },
        # destroy action
        { user: nil, action: :destroy, response: 403 },
        { user: '@creator', action: :destroy, response: 302 },
        { user: '@non_creator', action: :destroy, response: 403 },
        { user: '@admin', action: :destroy, response: 302 },
        { user: '@lister', action: :destroy, response: 403 },
        # add
        { user: nil, action: :add_entity, response: 403 },
        { user: '@creator', action: :add_entity, response: 302 },
        { user: '@non_creator', action: :add_entity, response: 403 },
        { user: '@admin', action: :add_entity, response: 302 },
        { user: '@lister', action: :add_entity, response: 403 },
        # remove
        { user: nil, action: :remove_entity, response: 403 },
        { user: '@creator', action: :remove_entity, response: 302 },
        { user: '@non_creator', action: :remove_entity, response: 403 },
        { user: '@admin', action: :remove_entity, response: 302 },
        { user: '@lister', action: :remove_entity, response: 403 },
        # new_entity associations action
        { user: nil, action: :new_entity_associations, response: 403 },
        { user: '@creator', action: :new_entity_associations, response: :success },
        { user: '@non_creator', action: :new_entity_associations, response: 403 },
        { user: '@admin', action: :new_entity_associations, response: :success },
        { user: '@lister', action: :new_entity_associations, response: 403 },
        # create entity associations action
        # TODO: why do the commented-out specs generate the following error:
        # No route matches {:action=>"/associations/entities", :controller=>"lists"}
        # { user: nil, action: :create_entity_associations, response: 403 },
        # { user: '@creator', action: :create_entity_associations, response: 302 },
        # { user: '@non_creator', action: :create_entity_associations, response: 403 },
        # { user: '@admin', action: :create_entity_associations, response: 302 },
        # { user: '@lister', action: :create_entity_associations, response: 403 },
        # update
        # in #update_entity, 404 = successful call that falls thru
        { user: nil, action: :remove_entity, response: 403 },
        { user: '@creator', action: :update_entity, response: 404 },
        { user: '@non_creator', action: :update_entity, response: 403 },
        { user: '@admin', action: :update_entity, response: 404 },
        { user: '@lister', action: :update_entity, response: 403 }
      ].each { |x| test_request_for_user(x) }
    end

    context 'closed list' do
      before do
        allow(ListDatatable).to receive(:new).and_return(spy('table'))
        allow(ListEntity).to receive(:find).and_return(spy('listentity'))
        allow(ListEntity).to receive(:find_or_create_by).and_return(spy('find_or_create_by'))
        @request.env["devise.mapping"] = Devise.mappings[:user]
        expect(List).to receive(:find).and_return(@closed_list)
      end

      [
        { user: nil, action: :members, response: :success },
        { user: '@creator', action: :members, response: :success },
        { user: '@non_creator', action: :members, response: :success },
        { user: '@lister', action: :members, response: :success },
        { user: '@admin', action: :members, response: :success },
        # interlocks action
        { user: nil, action: :interlocks, response: :success },
        { user: '@creator', action: :interlocks, response: :success },
        { user: '@non_creator', action: :interlocks, response: :success },
        { user: '@lister', action: :interlocks, response: :success },
        { user: '@admin', action: :interlocks, response: :success },
        # giving action
        { user: nil, action: :giving, response: :success },
        { user: '@creator', action: :giving, response: :success },
        { user: '@non_creator', action: :giving, response: :success },
        { user: '@lister', action: :giving, response: :success },
        { user: '@admin', action: :giving, response: :success },
        # funding action
        { user: nil, action: :funding, response: :success },
        { user: '@creator', action: :funding, response: :success },
        { user: '@non_creator', action: :funding, response: :success },
        { user: '@lister', action: :funding, response: :success },
        { user: '@admin', action: :funding, response: :success },
        # references action
        { user: nil, action: :references, response: :success },
        { user: '@creator', action: :references, response: :success },
        { user: '@non_creator', action: :references, response: :success },
        { user: '@lister', action: :references, response: :success },
        { user: '@admin', action: :references, response: :success },
        # edit action
        { user: nil, action: :edit, response: 403 },
        { user: '@creator', action: :edit, response: :success },
        { user: '@non_creator', action: :edit, response: 403 },
        { user: '@admin', action: :edit, response: :success },
        { user: '@lister', action: :edit,response: 403 },
        # update action
        { user: nil, action: :update, response: 403 },
        { user: '@creator', action: :update, response: 302 },
        { user: '@non_creator', action: :update, response: 403 },
        { user: '@admin', action: :update, response: 302 },
        { user: '@lister', action: :update,response: 403 },
        # destroy action
        { user: nil, action: :destroy, response: 403 },
        { user: '@creator', action: :destroy, response: 302 },
        { user: '@non_creator', action: :destroy, response: 403 },
        { user: '@admin', action: :destroy, response: 302 },
        { user: '@lister', action: :destroy, response: 403 },
        # add entity
        { user: nil, action: :add_entity, response: 403 },
        { user: '@creator', action: :add_entity, response: 302 },
        { user: '@non_creator', action: :add_entity, response: 403 },
        { user: '@admin', action: :add_entity, response: 302 },
        { user: '@lister', action: :add_entity, response: 403 },
        # remove entity
        { user: nil, action: :remove_entity, response: 403 },
        { user: '@creator', action: :remove_entity, response: 302 },
        { user: '@non_creator', action: :remove_entity, response: 403 },
        { user: '@admin', action: :remove_entity, response: 302 },
        { user: '@lister', action: :remove_entity, response: 403 },
        # new entity associations action
        { user: nil, action: :new_entity_associations, response: 403 },
        { user: '@creator', action: :new_entity_associations, response: :success },
        { user: '@non_creator', action: :new_entity_associations, response: 403 },
        { user: '@admin', action: :new_entity_associations, response: :success },
        { user: '@lister', action: :new_entity_associations, response: 403 },
        # create entity associations action
        # TODO: why do the commented-out specs generate the following error:
        # No route matches {:action=>"/associations/entities", :controller=>"lists"}
        # { user: nil, action: :create_entity_associations, response: 403 },
        # { user: '@creator', action: :create_entity_associations, response: 302 },
        # { user: '@non_creator', action: :create_entity_associations, response: 403 },
        # { user: '@admin', action: :create_entity_associations, response: 302 },
        # { user: '@lister', action: :create_entity_associations, response: 403 },
        # update entity
        # in #update_entity, 404 = successful call that falls thru
        { user: nil, action: :remove_entity, response: 403 },
        { user: '@creator', action: :update_entity, response: 404 },
        { user: '@non_creator', action: :update_entity, response: 403 },
        { user: '@admin', action: :update_entity, response: 404 },
        { user: '@lister', action: :update_entity, response: 403 }
      ].each { |x| test_request_for_user(x) }
    end
  end

  describe "#set_permisions" do
    before do
      @controller = ListsController.new
      @user = create_basic_user
      @list = build(:list, access: Permissions::ACCESS_OPEN, creator_user_id: @user.id)
      @controller.instance_variable_set(:@list, @list)
    end

    it "sets permissions for a logged-in user" do
      allow(@controller).to receive(:current_user).and_return(@user)
      expect(@user.permissions).to receive(:list_permissions).with(@list)
      @controller.send(:set_permissions)
    end

    it "sets permissions for an anonymous user" do
      allow(@controller).to receive(:current_user).and_return(nil)
      expect(Permissions).to receive(:anon_list_permissions).with(@list)
      @controller.send(:set_permissions)
    end
  end
end
