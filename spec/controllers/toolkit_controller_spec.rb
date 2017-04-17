require 'rails_helper'

describe ToolkitController, type: :controller do
  it { should route(:get, '/toolkit').to(action: :index) }
  it { should route(:get, '/toolkit/new').to(action: :new_page) }
  it { should route(:get, '/toolkit/some_page').to(action: :display, toolkit_page: 'some_page') }
  it { should route(:get, '/toolkit/another_page').to(action: :display, toolkit_page: 'another_page') }
  it { should route(:post, '/toolkit/create_new_page').to(action: :create_new_page) }
  it { should route(:get, '/toolkit/page/edit').to(action: :edit, toolkit_page: 'page') }
  it { should route(:patch, '/toolkit/123').to(action: :update, id: '123') }

  describe 'display' do
    login_user
    before(:all) do
      ToolkitPage.create!(name: 'interesting_facts', title: 'interesting facts', markdown: '# interesting facts')
    end

    it 'responds with 404 if page does not exist' do
      get :display, toolkit_page: 'not_a_page_yet'
      expect(response).to have_http_status(404)
    end

    it 'renders display if page exists' do
      get :display, toolkit_page: 'interesting_facts'
      expect(response).to have_http_status(200)
      expect(response).to render_template(:display)
    end

    it 'can accept page names with spaces and capitals' do
      get :display, toolkit_page: 'iNtErEsTiNg FaCtS'
      expect(response).to have_http_status(200)
      expect(response).to render_template(:display)
    end
  end

  describe 'edit' do
    login_admin
    
    before(:all) do
      ToolkitPage.delete_all
      @toolkit_page = ToolkitPage.create!(name: 'interesting_facts', title: 'interesting facts')
    end

    before do
      expect(controller).to receive(:authenticate_user!).once
      expect(controller).to receive(:admins_only).once
    end

    it 'responds with 404 if page does not exist' do
      get :edit, toolkit_page: 'not_a_page_yet'
      expect(response).to have_http_status 404
    end

    it 'renders edit page' do
      get :edit, toolkit_page: 'interesting_facts'
      expect(response).to have_http_status 200
      expect(response).to render_template :edit
    end

    it 'assigns toolkit_page' do
      get :edit, toolkit_page: 'interesting_facts'
      expect(controller.instance_variable_get('@toolkit_page')).to eq @toolkit_page
    end
  end

  describe '#index' do
    login_user
    before do
      get :index
    end
    it { should respond_with(:success) }
    it { should render_template(:index) }
    it { should render_with_layout('toolkit') }
  end

  describe '#new_page' do
    login_admin
    before { get :new_page }
    it { should respond_with(:success) }
    it { should render_template(:new_page) }
  end

  describe '#create_new_page' do
    login_admin
    let(:good_params) { { 'toolkit_page' => { 'name' => 'some_page', 'title' => 'page title' } } }
    let(:bad_params) { { 'toolkit_page' => { 'title' => 'page title' } } }

    context 'good post' do
      it 'creates a new toolkit page' do
        expect { post :create_new_page, good_params }
          .to change { ToolkitPage.count }.by(1)
      end

      it 'sets last_user_id' do
        expect(ToolkitPage).to receive(:new)
                                .with(hash_including(:last_user_id => controller.current_user.id))
                                .and_return(spy('toolkit page'))
        post :create_new_page, good_params
      end
    end

    context 'bad post' do
      it 'does not create a new toolkit page' do
        expect { post :create_new_page, bad_params }
          .not_to change { ToolkitPage.count }
      end

      it 'renders new page' do
        post :create_new_page, bad_params
        expect(response).to render_template(:new_page)
      end
    end
  end

  describe '#update' do
    login_admin
    let(:params) { {'id' => @page.id, 'toolkit_page' => { 'markdown' => '# part one' } } }

    before do
      @page = ToolkitPage.create!(name: 'cats_in_government', title: 'cats in government', markdown: '# markdown')
    end

    it 'updates markdown' do
      expect { patch :update, params }.to change { @page.reload.markdown }.to('# part one')
    end

    it 'redirects to display page' do
      patch :update, params
      expect(response).to redirect_to '/toolkit/cats_in_government'
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
