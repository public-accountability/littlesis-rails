describe ToolkitController, type: :controller do
  after(:all) { ToolkitPage.delete_all }
  before(:all) { ToolkitPage.delete_all }

  it { is_expected.to route(:get, '/toolkit').to(action: :index) }
  it { is_expected.to route(:get, '/toolkit/new').to(action: :new) }
  it { is_expected.to route(:get, '/toolkit/some_page').to(action: :display, page_name: 'some_page') }
  it { is_expected.to route(:get, '/toolkit/another_page').to(action: :display, page_name: 'another_page') }
  it { is_expected.to route(:post, '/toolkit').to(action: :create) }
  it { is_expected.to route(:get, '/toolkit/page/edit').to(action: :edit, page_name: 'page') }
  it { is_expected.to route(:patch, '/toolkit/123').to(action: :update, id: '123') }

  describe 'display' do
    before(:all) do
      ToolkitPage.create!(name: 'interesting_facts', title: 'interesting facts', content: '# interesting facts')
    end

    it 'responds with 404 if page does not exist' do
      get :display, params: { page_name: 'not_a_page_yet' }
      expect(response).to have_http_status(:not_found)
    end

    it 'renders display if page exists' do
      get :display, params: { page_name: 'interesting_facts' }
      expect(response).to have_http_status(:ok)
      expect(response).to render_template(:display)
    end

    it 'can accept page names with spaces and capitals' do
      get :display, params: { page_name: 'iNtErEsTiNg FaCtS' }
      expect(response).to have_http_status(:ok)
      expect(response).to render_template(:display)
    end

    it 'sets cache-control headers' do
      get :display, params: { page_name: 'interesting_facts' }
      expect(response.headers['Cache-Control']).to include 'max-age=86400, public'
    end
  end

  describe 'edit' do
    let!(:page) { ToolkitPage.create!(name: 'uninteresting_factoids', title: 'uninteresting factoids') }

    before do
      expect(controller).to receive(:authenticate_user!).once
      expect(controller).to receive(:admins_only).once
    end

    it 'responds with 404 if page does not exist' do
      get :edit, params: { page_name: 'not_a_page_yet' }
      expect(response).to have_http_status :not_found
    end

    it 'renders edit page' do
      get :edit, params: { page_name: 'uninteresting_factoids' }
      expect(response).to have_http_status :ok
      expect(response).to render_template :edit
    end

    it 'assigns toolkit_page' do
      get :edit, params: { page_name: 'uninteresting_factoids' }
      expect(assigns(:page)).to eq page
    end
  end

  describe '#index' do
    before { get :index }

    it { is_expected.to respond_with(:success) }
    it { is_expected.to render_template(:index) }
    it { is_expected.to render_with_layout('toolkit') }

    it 'sets cache-control headers' do
      expect(response.headers['Cache-Control']).to include 'max-age=86400, public'
    end
  end

  describe '#new' do
    before do
      sign_in create_admin_user
      get :new
    end

    it { is_expected.to respond_with(:success) }
    it { is_expected.to render_template(:new) }
  end

  describe '#create' do
    let(:good_params) { { 'toolkit_page' => { 'name' => 'some_page', 'title' => 'page title' } } }
    let(:bad_params) { { 'toolkit_page' => { 'title' => 'page title' } } }

    before do
      sign_in create_admin_user
    end

    context 'with good post' do
      it 'creates a new toolkit page' do
        expect { post :create, params: good_params }
          .to change(ToolkitPage, :count).by(1)
      end

      it 'sets last_user_id' do
        post :create, params: good_params
        expect(ToolkitPage.last.last_user_id).to eq controller.current_user.id
      end
    end

    context 'with bad post' do
      it 'does not create a new toolkit page' do
        expect { post :create, params: bad_params }
          .not_to change(ToolkitPage, :count)
      end

      it 'renders new page' do
        post :create, params: bad_params
        expect(response).to render_template(:new)
      end
    end
  end

  describe '#update' do
    let(:page) { ToolkitPage.create!(name: 'cats_in_government', title: 'cats in government') }
    let(:params) { { id: page.id, toolkit_page: { title: 'Part One' } } }

    before do
      sign_in create_admin_user
    end

    it 'updates title' do
      expect { patch :update, params: params }.to change { page.reload.title }.to('Part One')
    end

    it 'redirects to display page' do
      patch :update, params: params
      expect(response).to redirect_to %r{/toolkit/cats_in_government}
    end
  end
end
