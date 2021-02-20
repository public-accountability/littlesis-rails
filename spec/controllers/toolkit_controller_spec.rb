describe ToolkitController, type: :controller do
  after(:all) { ToolkitPage.delete_all }
  before(:all) { ToolkitPage.delete_all }

  it { should route(:get, '/toolkit').to(action: :index) }
  it { should route(:get, '/toolkit/new').to(action: :new) }
  it { should route(:get, '/toolkit/some_page').to(action: :display, page_name: 'some_page') }
  it { should route(:get, '/toolkit/another_page').to(action: :display, page_name: 'another_page') }
  it { should route(:post, '/toolkit').to(action: :create) }
  it { should route(:get, '/toolkit/page/edit').to(action: :edit, page_name: 'page') }
  it { should route(:patch, '/toolkit/123').to(action: :update, id: '123') }

  it 'has MARKDOWN constant' do
    expect(ToolkitController::MARKDOWN).to be_a(Redcarpet::Markdown)
  end

  describe 'display' do
    before(:all) do
      ToolkitPage.create!(name: 'interesting_facts', title: 'interesting facts', markdown: '# interesting facts')
    end

    it 'responds with 404 if page does not exist' do
      get :display, params: { page_name: 'not_a_page_yet' }
      expect(response).to have_http_status(404)
    end

    it 'renders display if page exists' do
      get :display, params: { page_name: 'interesting_facts' }
      expect(response).to have_http_status(200)
      expect(response).to render_template(:display)
    end

    it 'can accept page names with spaces and capitals' do
      get :display, params: { page_name: 'iNtErEsTiNg FaCtS' }
      expect(response).to have_http_status(200)
      expect(response).to render_template(:display)
    end

    it 'sets cache-control headers' do
      get :display, params: { page_name: 'interesting_facts' }
      expect(response.headers['Cache-Control']).to include 'max-age=86400, public'
    end
  end

  describe 'edit' do
    before(:all) do
      ToolkitPage.delete_all
      @toolkit_page = ToolkitPage.create!(name: 'interesting_facts', title: 'interesting facts')
    end

    before do
      expect(controller).to receive(:authenticate_user!).once
      expect(controller).to receive(:admins_only).once
    end

    it 'responds with 404 if page does not exist' do
      get :edit, params: { page_name: 'not_a_page_yet' }
      expect(response).to have_http_status 404
    end

    it 'renders edit page' do
      get :edit, params: { page_name: 'interesting_facts' }
      expect(response).to have_http_status 200
      expect(response).to render_template :edit
    end

    it 'assigns toolkit_page' do
      get :edit, params: { page_name: 'interesting_facts' }
      expect(controller.instance_variable_get('@page')).to eq @toolkit_page
    end
  end

  describe '#index' do
    before { get :index }
    it { should respond_with(:success) }
    it { should render_template(:index) }
    it { should render_with_layout('toolkit') }

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

    context 'good post' do
      it 'creates a new toolkit page' do
        expect { post :create, params: good_params }
          .to change(ToolkitPage, :count).by(1)
      end

      it 'sets last_user_id' do
        expect(ToolkitPage).to receive(:new)
                                 .with(hash_including(:last_user_id => controller.current_user.id))
                                 .and_return(spy('toolkit page'))
        post :create, params: good_params
      end
    end

    context 'bad post' do
      it 'does not create a new toolkit page' do
        expect { post :create, params: bad_params }
          .not_to change { ToolkitPage.count }
      end

      it 'renders new page' do
        post :create, params: bad_params
        expect(response).to render_template(:new)
      end
    end
  end

  describe '#update' do
    let(:params) { { 'id' => @page.id, 'toolkit_page' => { 'markdown' => '# part one' } } }

    before do
      sign_in create_admin_user
      @page = ToolkitPage.create!(name: 'cats_in_government', title: 'cats in government', markdown: '# markdown')
    end

    it 'updates markdown' do
      expect { patch :update, params: params }.to change { @page.reload.markdown }.to('# part one')
    end

    it 'redirects to display page' do
      patch :update, params: params
      expect(response).to redirect_to %r{/toolkit/cats_in_government}
    end
  end

  describe '#markdown' do
    it 'can render markdown' do
      c = ToolkitController.new
      expect(c.send(:markdown, '# i am markdown'))
        .to eq "<h1>i am markdown</h1>\n"
    end
  end
end
