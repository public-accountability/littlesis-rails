require 'rails_helper'

describe 'Users' do
  describe '/users/check_username' do
    subject { json }

    let(:username) { '' }

    before do
      get '/users/check_username', params: { 'username' => username }
    end

    context 'with valid username' do
      let(:username) { FactoryBot.attributes_for(:user)[:username] }

      it do
        is_expected.to eq('username' => username, 'valid' => true)
      end
    end

    context 'with invalid username' do
      let(:username) { '12356' }

      it do
        is_expected.to eq('username' => username, 'valid' => false)
      end
    end
  end

  describe 'attempting to add an ability that does not exist' do
    let(:user) { create_basic_user }
    let(:admin) { create_admin_user }

    before do
      user
      login_as(admin, :scope => :user)
      post "/users/#{user.id}/add_permission", params: { permission: 'dance' }
    end

    after { logout(:user) }

    it 'returns a bad request' do
      expect(response).to have_http_status :bad_request
      expect(response.body).to be_blank
    end
  end
end
