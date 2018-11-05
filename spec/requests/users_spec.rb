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
end
