require 'rails_helper'

describe PagesController, type: :controller do
  it { should route(:get, '/oligrapher').to(action: :oligrapher_splash) }
  it { should route(:get, '/partypolitics').to(action: :partypolitics) }
  it { should route(:get, '/about').to(action: :display, page: 'about') }
  it { should_not route(:post, '/about').to(action: :display, page: 'about') }
  it { should route(:get, '/features').to(action: :display, page: 'features') }
  it { should_not route(:get, '/bad_page').to(action: :display) }
  it { should route(:get, '/pages/new').to(action: :new) }
  it { should route(:get, '/pages/666').to(action: :show, id: '666') }
  it { should route(:get, '/pages/666/edit').to(action: :edit, id: '666') }
  it { should route(:get, '/pages/some_page/edit').to(action: :edit_by_name, page: 'some_page') }
  it { should route(:get, '/pages/about/edit').to(action: :edit_by_name, page: 'about') }
  it { should route(:patch, '/pages/666').to(action: :update, id: '666') }
  it { should route(:post, '/pages').to(action: :create) }
  it { should route(:get, '/pages').to(action: :index) }

  it 'has MARKDOWN constant' do
    expect(ToolkitController::MARKDOWN).to be_a(Redcarpet::Markdown)
  end

  describe '#display - GET /features' do
    before(:all) do
      Page.create!(name: 'features', title: 'features', markdown: '# features')
    end

    before { get :display, page: 'features' }

    it { should respond_with(200) }

    it 'sets cache-control headers' do
      expect(response.headers['Cache-Control']).to include 'max-age=3600, public'
    end
  end

  describe 'create page' do
    let(:params) { { page: { name: 'new_page', title: 'this is a new page' } } }
    login_admin

    it 'creates new page' do
      expect { post :create, params }.to change { Page.count }.by(1)
    end
  end

  describe 'edit_by_name' do
    login_admin

    before do
      @page = Page.create!(name: 'people', title: 'people', markdown: '# markdown')
    end

    it 'redirects to /pages/id/edit' do
      get :edit_by_name, page: 'people'
      expect(response).to redirect_to("/pages/#{@page.id}/edit")
    end
  end

  describe '#update' do
    login_admin
    let(:params) { {'id' => @page.id, 'page' => { 'markdown' => '# part one' } } }

    before do
      @page = Page.create!(name: 'about', title: 'about us', markdown: '# markdown')
    end

    it 'updates markdown' do
      expect { patch :update, params }.to change { @page.reload.markdown }.to('# part one')
    end

    it 'redirects to display page' do
      patch :update, params
      expect(response).to redirect_to '/about'
    end
  end
end
