describe ListsController, type: :controller do
  it { is_expected.to route(:delete, '/lists/1').to(action: :destroy, id: 1) }
  it { is_expected.to route(:post, '/lists/1/tags').to(action: :tags, id: 1) }
  it { is_expected.to route(:get, '/lists/1234-list-name/modifications').to(action: :modifications, id: '1234-list-name') }

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

  describe 'POST create with restricted user' do
    login_restricted_user

    let(:create_list_post) do
      post :create, params: { list: { name: 'list name' }, ref: { url: 'http://mysource' } }
    end

    it 'does not create a list' do
      expect { create_list_post }.not_to change(List, :count)
    end
  end

  describe 'POST create' do
    login_user

    context 'when missing name' do
      let(:params) { { list: { name: '' }, ref: { url: 'http://mysource' } } }

      before { post :create, params: params }

      it 'raises a validation error for the missing name' do
        expect(response).to render_template(:new)
        expect(assigns(:list).errors.size).to eq(1)
        expect(assigns(:list).errors.full_messages.first).to eq "Name can't be blank"
      end
    end

    context 'when missing source' do
      it 'creates the list without a reference' do
        expect {
          post :create, params: { list: { name: 'a name' }, ref: { url: '' } }
        }.to change(List, :count).by(1)
        expect(assigns(:list).references.count).to be 0
      end
    end

    context 'with name and source' do
      it 'redirects to the newly created list' do
        post :create,  params: { list: { name: 'list name' }, ref: { url: 'http://mysource' } }
        expect(response).to redirect_to(assigns(:list))
      end

      it 'saves the list' do
        expect do
          post :create, params: { list: { name: 'list name' }, ref: { url: 'http://mysource' } }
        end.to change(List, :count).by(1)
      end

      it 'creates a reference for the list' do
        expect do
          post :create, params: { list: { name: 'list name' }, ref: { url: 'http://mysource' } }
        end.to change(Reference, :count).by(1)

        expect(Reference.last.referenceable_id).to eql assigns(:list).id
        expect(Reference.last.referenceable_type).to eql 'List'
      end

      it 'creates a reference with a name provided' do
        params = { list: { name: 'list name' }, ref: { url: 'http://mysource', name: 'important source' } }
        post :create, params: params
        expect(Reference.last.document.name).to eql 'important source'
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
    let(:list) { create(:list) }

    it 'redirects to the members page' do
      get :show, params: { id: list.id }
      expect(response).to redirect_to(action: :members)
    end
  end

  describe 'members' do
    before do
      get :members, params: { id: list.id }
    end

    context 'with a sorted list' do
      let(:list) { create(:list, sort_by: :total_usd_donations) }

      it 'specifies sort_by in the datatable config' do
        expect(assigns[:datatable_config][:sort_by]).to eq 'total_usd_donations'
      end
    end

    context 'with a ranked list' do
      let(:list) { create(:list, is_ranked: true) }

      it 'specifies is ranked in the datatable config' do
        expect(assigns[:datatable_config][:ranked_table]).to be true
      end
    end

    context 'with an editable list' do
      let(:list) { create(:list) }
      let!(:admin) { create_admin_user }

      before do
        sign_in admin
        get :members, params: { id: list.id }
      end

      it 'specifies is editable in the datatable config' do
        expect(assigns[:datatable_config][:editable]).to be true
      end
    end
  end

  context 'with a list of people' do
    let(:list) { create(:list) }
    let(:person) { create(:entity_person) }

    before do
      ListEntity.create!(list_id: list.id, entity_id: person.id)
      Link.refresh
    end

    describe 'interlocks' do
      before do
        get :interlocks, params: { id: list.id }
      end

      it { is_expected.to respond_with(:success) }
    end

    describe 'giving' do
      before do
        get :giving, params: { id: list.id }
      end

      it { is_expected.to respond_with(:success) }
    end

    describe 'funding' do
      before do
        get :funding, params: { id: list.id }
      end

      it { is_expected.to respond_with(:success) }
    end

    describe 'government' do
      before do
        get :government, params: { id: list.id }
      end

      it { is_expected.to respond_with(:success) }
    end
  end

  describe 'List access controls' do
    let(:creator) { create_basic_user }
    let(:non_creator) { create_really_basic_user }
    let(:lister) { create_basic_user }
    let(:admin) { create_admin_user }
    let(:open_list) { create(:open_list, creator_user_id: creator.id) }
    let(:closed_list) { create(:closed_list, creator_user_id: creator.id) }
    let(:private_list) { create(:private_list, creator_user_id: creator.id) }

    # before do
    #   allow(controller).to receive(:interlocks_query)
    #   allow(controller).to receive(:interlocks_results)
    # end
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
