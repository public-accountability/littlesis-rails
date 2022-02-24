describe PagesController, type: :controller do
  it { is_expected.to route(:get, '/oligrapher/about').to(action: :oligrapher) }
  it { is_expected.to route(:get, '/donate').to(action: :donate) }
  it { is_expected.to route(:get, '/about').to(action: :about) }
  it { is_expected.to route(:get, '/disclaimer').to(action: :disclaimer) }
  it { is_expected.not_to route(:get, '/bad_page').to(action: :display) }
  it { is_expected.to route(:get, '/pages/new').to(action: :new) }
  it { is_expected.to route(:get, '/pages/666').to(action: :show, id: '666') }
  it { is_expected.to route(:get, '/pages/666/edit').to(action: :edit, id: '666') }
  it { is_expected.to route(:get, '/pages/some_page/edit').to(action: :edit_by_name, page: 'some_page') }
  it { is_expected.to route(:get, '/pages/about/edit').to(action: :edit_by_name, page: 'about') }
  it { is_expected.to route(:patch, '/pages/666').to(action: :update, id: '666') }
  it { is_expected.to route(:post, '/pages').to(action: :create) }
  it { is_expected.to route(:get, '/pages').to(action: :index) }
  it { is_expected.to route(:get, '/swamped').to(action: :swamped) }
  it { is_expected.to route(:post, '/swamped').to(action: :swamped) }
  it { is_expected.to route(:get, '/bulk_data').to(action: :bulk_data) }
  it { is_expected.to route(:get, '/public_data/relationships.json.gz').to(action: :public_data, file: 'relationships.json.gz') }
  it { is_expected.not_to route(:get, '/public_data/example.json').to(action: :public_data) }

  describe 'create page' do
    let(:params) { { page: { name: 'new_page', title: 'this is a new page' } } }

    login_admin

    it 'creates new page' do
      expect { post :create, params: params }.to change(Page, :count).by(1)
    end
  end

  describe 'edit_by_name' do
    login_admin

    let(:page) do
      Page.create!(name: 'people', title: 'people', content: '<h1>People</h1>')
    end

    it 'redirects to /pages/id/edit' do
      get :edit_by_name, params: { page: page.title }
      expect(response).to redirect_to("/pages/#{page.id}/edit")
    end
  end

  describe '#update' do
    login_admin
    let(:page) { Page.create!(name: 'news', title: 'news', content: '<h1>news...</h1>') }
    let(:params) { { id: page.id, page: { title: 'more news' } } }

    it 'updates title' do
      expect { patch :update, params: params }.to change { page.reload.title }.to('more news')
    end

    it 'redirects to display page' do
      patch :update, params: params
      expect(response).to redirect_to '/news'
    end
  end
end
