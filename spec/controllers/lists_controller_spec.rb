describe ListsController, :list_helper, type: :controller do
  before(:all) { DatabaseCleaner.start }
  after(:all) { DatabaseCleaner.clean }

  it { is_expected.to route(:delete, '/lists/1').to(action: :destroy, id: 1) }
  it { is_expected.to route(:post, '/lists/1/tags').to(action: :tags, id: 1) }
  it { is_expected.to route(:get, '/lists/1234-list-name/modifications').to(action: :modifications, id: '1234-list-name') }
  it { is_expected.to route(:get, '/lists/1/entities/bulk').to(action: :new_entity_associations, id: 1) }
  it { is_expected.to route(:post, '/lists/1/entities/bulk').to(action: :create_entity_associations, id: 1) }

  describe 'GET /lists' do
    let(:inc) { create(:entity_org) }
    let(:list_owner) { create_basic_user }
    let!(:restricted_user) { create_restricted_user }
    let!(:permitted_lister) { create_basic_user }
    let!(:private_list) { create(:list, name: 'my private list', access: Permissions::ACCESS_PRIVATE, creator_user_id: list_owner.id) }
    let!(:open_list) { create(:list, name: 'public list', access: Permissions::ACCESS_OPEN) }
    let!(:closed_list) { create(:list, name: 'my closed list', access: Permissions::ACCESS_CLOSED, creator_user_id: list_owner.id) }
    let!(:other_list) { create(:list, name: "someone else's private list", access: Permissions::ACCESS_PRIVATE, creator_user_id: permitted_lister.id) }

    before do
      [private_list, open_list, closed_list, other_list].each do |list|
        ListEntity.find_or_create_by(list_id: list.id, entity_id: inc.id)
      end
    end

    context 'with the list owner logged in' do
      before do
        sign_in list_owner
        get :index
      end

      it { is_expected.to respond_with(:success) }
      it { is_expected.to render_template(:index) }

      it 'only returns public lists and private lists created by the current user' do
        expect(assigns(:lists)).to include(open_list, private_list, closed_list)
        expect(assigns(:lists)).not_to include(other_list)
      end

      it '@lists has correct names' do
        expect(assigns(:lists).map(&:name)).to include('public list', 'my private list', 'my closed list')
      end
    end

    context 'with the user logged out' do
      before do
        get :index
      end

      it { is_expected.to respond_with(:success) }
      it { is_expected.to render_template(:index) }

      it 'only returns public lists' do
        expect(assigns(:lists)).to include(open_list, closed_list)
        expect(assigns(:lists)).not_to include(other_list, private_list)
      end
    end

    context 'with a restricted user logged in' do
      before do
        sign_in restricted_user
        get :index
      end

      it { is_expected.to respond_with(:success) }
      it { is_expected.to render_template(:index) }

      it 'only returns public lists' do
        expect(assigns(:lists)).to include(open_list, closed_list)
        expect(assigns(:lists)).not_to include(other_list, private_list)
      end
    end
  end

  describe 'get editable lists' do
    let(:list_owner) { create_basic_user }
    let!(:restricted_user) { create_restricted_user }
    let!(:permitted_lister) { create_basic_user }
    let!(:private_list) { create(:list, access: Permissions::ACCESS_PRIVATE, creator_user_id: list_owner.id) }
    let!(:public_list) { create(:list, access: Permissions::ACCESS_OPEN) }
    let!(:closed_list) { create(:list, access: Permissions::ACCESS_CLOSED, creator_user_id: list_owner.id) }

    context 'with a logged in list owner' do
      before do
        sign_in(list_owner)
        get :index, params: { editable: true }
      end

      it 'includes all editable lists' do
        expect(assigns(:lists)).to include(private_list, public_list, closed_list)
      end
    end

    context 'with a lister other than the private list owner' do
      before do
        sign_in(permitted_lister)
        get :index, params: { editable: true }
      end

      it "does not include other people's private lists or closed lists" do
        expect(assigns(:lists)).not_to include(private_list, closed_list)
      end

      it "includes public lists" do
        expect(assigns(:lists)).to include(public_list)
      end
    end

    context 'with no list permissions' do
      before do
        sign_in(restricted_user)
        get :index, params: { editable: true }
      end

      it "returns no lists" do
        expect(assigns(:lists)).to be_empty
      end
    end
  end

  context 'if user is restricted' do
    login_restricted_user
    let(:create_list_post) do
      post :create, params: { list: { name: 'list name' }, ref: { url: 'http://mysource' } }
    end

    it 'does not create a list' do
      expect { create_list_post }.not_to change { List.count }
    end
  end

  describe 'POST create' do
    login_user

    context 'When missing name and url' do
      let(:params) { { list: { name: '' }, ref: { url: '' } } }
      before { post :create, params: params }
      specify { expect(response).to render_template(:new) }
      specify { expect(assigns(:list).errors.size).to eq(2) }
    end

    context 'When missing just name or just source' do
      it 'renders new template' do
        post :create, params: { list: { name: 'a name' }, ref: { url: '' } }
        expect(response).to render_template(:new)
      end

      it 'has one error - blank name' do
        post :create, params: { list: { name: '' }, ref: { url: 'http://mysource' } }
        expect(assigns(:list).errors.size).to eq 1
      end

      it 'has one error - missing source' do
        post :create, params: { list: { name: 'the list name' }, ref: { url: '' } }
        expect(assigns(:list).errors.size).to eq 1
      end
    end

    context 'submission with name and source' do
      it 'redirects to the newly created list' do
        post :create,  params: { list: { name: 'list name' }, ref: { url: 'http://mysource' } }
        expect(response).to redirect_to(assigns(:list))
      end

      it 'saves the list' do
        expect do
          post :create, params: { list: { name: 'list name' }, ref: { url: 'http://mysource' } }
        end.to change { List.count }.by(1)
        expect(List.last).to eql assigns(:list)
      end

      it 'create a reference with a name provided' do
        expect do
          post :create, params: { list: { name: 'list name' }, ref: { url: 'http://mysource' } }
        end.to change { Reference.count }.by(1)

        expect(Reference.last.referenceable_id).to eql assigns(:list).id
        expect(Reference.last.referenceable_type).to eql 'List'
        # the reference name is set to be the same as the the source url if no name isprovided
        expect(Reference.last.document.url).to eql 'http://mysource'
      end

      it 'creates a reference with a name provided' do
        params = { list: { name: 'list name' }, ref: { url: 'http://mysource', name: 'important source' } }
        post :create, params: params
        expect(Reference.last.document.name).to eql'important source'
        expect(Reference.last.document.url).to eql 'http://mysource'
      end
    end

    xdescribe 'modifications' do
      let(:new_list) { create(:list) }
      before { get :modifications, params: { id: new_list.id } }

      it 'renders modifications template' do
        expect(response).to render_template(:modifications)
      end

      it 'has @versions' do
        expect(assigns(:versions)).to eq(new_list.versions)
      end
    end
  end

  describe 'show' do
    before do
      expect(List).to receive(:find).and_return(build(:list))
      get :show, params: { id: 1 }
    end
    it { should respond_with(302) }
    it { should redirect_to(action: :members) }
  end

  describe 'remove_entity' do
    login_admin
    let(:list) { create(:list) }
    let(:person) { create(:entity_person) }
    let!(:list_entity) { ListEntity.create!(list_id: list.id, entity_id: person.id) }

    let(:post_remove_entity) do
      proc do
        post :remove_entity, params: { id: list.id, list_entity_id: list_entity.id }
      end
    end

    it 'removes the list entity' do
      expect(&post_remove_entity).to change { ListEntity.count }.by(-1)
    end

    it 'redirects to the members page' do
      post_remove_entity.call
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
        allow(List).to receive(:find).and_return(@open_list)
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
        { user: nil, action: :edit, response: :login_redirect },
        { user: '@creator', action: :edit, response: :success },
        { user: '@non_creator', action: :edit, response: 403 },
        { user: '@admin', action: :edit, response: :success },
        { user: '@lister', action: :edit, response: 403 },
        # update action
        { user: nil, action: :update, response: :login_redirect },
        { user: '@creator', action: :update, response: 302 },
        { user: '@non_creator', action: :update, response: 403 },
        { user: '@admin', action: :update, response: 302 },
        { user: '@lister', action: :update, response: 403 },
        # destroy action
        { user: nil, action: :destroy, response: :login_redirect },
        { user: '@creator', action: :destroy, response: 302 },
        { user: '@non_creator', action: :destroy, response: 403 },
        { user: '@admin', action: :destroy, response: 302 },
        { user: '@lister', action: :destroy, response: 403 },
        # add entity
        { user: nil, action: :add_entity, response: :login_redirect },
        { user: '@creator', action: :add_entity, response: 302 },
        { user: '@non_creator', action: :add_entity, response: 403 },
        { user: '@admin', action: :add_entity, response: 302 },
        { user: '@lister', action: :add_entity, response: 302 },
        # remove entity
        { user: nil, action: :remove_entity, response: :login_redirect },
        { user: '@creator', action: :remove_entity, response: 302 },
        { user: '@non_creator', action: :remove_entity, response: 403 },
        { user: '@admin', action: :remove_entity, response: 302 },
        { user: '@lister', action: :remove_entity, response: 302 },
        # new_entity associations action
        { user: nil, action: :new_entity_associations, response: :login_redirect },
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
        { user: nil, action: :remove_entity, response: :login_redirect },
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
        allow(List).to receive(:find).and_return(@private_list)
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
        { user: nil, action: :update, response: :login_redirect },
        { user: '@creator', action: :update, response: 302 },
        { user: '@non_creator', action: :update, response: 403 },
        { user: '@admin', action: :update, response: 302 },
        { user: '@lister', action: :update, response: 403 },
        # destroy action
        { user: nil, action: :destroy, response: :login_redirect },
        { user: '@creator', action: :destroy, response: 302 },
        { user: '@non_creator', action: :destroy, response: 403 },
        { user: '@admin', action: :destroy, response: 302 },
        { user: '@lister', action: :destroy, response: 403 },
        # add
        { user: nil, action: :add_entity, response: :login_redirect },
        { user: '@creator', action: :add_entity, response: 302 },
        { user: '@non_creator', action: :add_entity, response: 403 },
        { user: '@admin', action: :add_entity, response: 302 },
        { user: '@lister', action: :add_entity, response: 403 },
        # remove
        { user: nil, action: :remove_entity, response: :login_redirect },
        { user: '@creator', action: :remove_entity, response: 302 },
        { user: '@non_creator', action: :remove_entity, response: 403 },
        { user: '@admin', action: :remove_entity, response: 302 },
        { user: '@lister', action: :remove_entity, response: 403 },
        # new_entity associations action
        { user: nil, action: :new_entity_associations, response: :login_redirect },
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
        { user: nil, action: :remove_entity, response: :login_redirect },
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
        allow(List).to receive(:find).and_return(@closed_list)
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
        { user: nil, action: :edit, response: :login_redirect },
        { user: '@creator', action: :edit, response: :success },
        { user: '@non_creator', action: :edit, response: 403 },
        { user: '@admin', action: :edit, response: :success },
        { user: '@lister', action: :edit, response: 403 },
        # update action
        { user: nil, action: :update, response: :login_redirect },
        { user: '@creator', action: :update, response: 302 },
        { user: '@non_creator', action: :update, response: 403 },
        { user: '@admin', action: :update, response: 302 },
        { user: '@lister', action: :update, response: 403 },
        # destroy action
        { user: nil, action: :destroy, response: :login_redirect },
        { user: '@creator', action: :destroy, response: 302 },
        { user: '@non_creator', action: :destroy, response: 403 },
        { user: '@admin', action: :destroy, response: 302 },
        { user: '@lister', action: :destroy, response: 403 },
        # add entity
        { user: nil, action: :add_entity, response: :login_redirect },
        { user: '@creator', action: :add_entity, response: 302 },
        { user: '@non_creator', action: :add_entity, response: 403 },
        { user: '@admin', action: :add_entity, response: 302 },
        { user: '@lister', action: :add_entity, response: 403 },
        # remove entity
        { user: nil, action: :remove_entity, response: :login_redirect },
        { user: '@creator', action: :remove_entity, response: 302 },
        { user: '@non_creator', action: :remove_entity, response: 403 },
        { user: '@admin', action: :remove_entity, response: 302 },
        { user: '@lister', action: :remove_entity, response: 403 },
        # new entity associations action
        { user: nil, action: :new_entity_associations, response: :login_redirect },
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
        { user: nil, action: :remove_entity, response: :login_redirect },
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
