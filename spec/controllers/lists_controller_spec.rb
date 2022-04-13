describe ListsController, type: :controller do
  it { is_expected.to route(:delete, '/lists/1').to(action: :destroy, id: 1) }
  it { is_expected.to route(:post, '/lists/1/tags').to(action: :tags, id: 1) }
  it { is_expected.to route(:get, '/lists/1234-list-name/modifications').to(action: :modifications, id: '1234-list-name') }

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

    describe 'modifications' do
      login_user
      let(:new_list) { create(:list, creator_user_id: example_user.id) }

      before { get :modifications, params: { id: new_list.id } }

      it 'renders modifications template' do
        expect(response).to render_template(:modifications)
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
end
