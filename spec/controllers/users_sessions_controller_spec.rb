require 'rails_helper'

describe Users::SessionsController, type: :controller do
  describe 'Routes' do
    it { should route(:get, '/login').to(action: :new) }
    it { should route(:post, '/login').to(action: :create) }
    it { should route(:get, '/logout').to(action: :destroy) }
  end

  describe 'X-Frame-Options' do
    before  { request.env['devise.mapping'] = Devise.mappings[:user] } 
    
    it 'sets for login' do
      get :new
      expect(response.headers['X-Frame-Options']).to eq 'ALLOW-FROM http://localhost:3000'
    end

    it 'sets for post login' do
      post :create
      expect(response.headers['X-Frame-Options']).to eq 'ALLOW-FROM http://localhost:3000'
    end

    it 'does not set for logout' do
      get :destroy
      expect(response.headers['X-Frame-Options']).to eq 'SAMEORIGIN'
    end
  end
end
