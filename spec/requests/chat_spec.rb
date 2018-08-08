require 'rails_helper'

describe 'Chat' do
  let(:user) { create_really_basic_user }

  context 'user is not signed in' do
    before { post '/chat_auth' }

    it 'request is unauthorized' do
      expect(response).to have_http_status 401
      expect(json['error']).to eql 'Missing email address or password'
    end
  end

  context 'user is restricted' do
    let(:user) { create_restricted_user }
    before do
      login_as(user, :scope => :user)
      post '/chat_auth'
    end
    after { logout(:user) }
    specify { expect(response).to have_http_status 401 }
  end

  context 'user is already signed in' do
    let(:chatid) { SecureRandom.hex }
    let(:login_token) { { 'token' => SecureRandom.hex } }

    before do
      expect(Chat).to receive(:login_token).with(chatid).and_return(login_token)
      user.update!(chatid: chatid)
      login_as(user, :scope => :user)
      post '/chat_auth'
    end

    after { logout(:user) }

    it 'returns successful response with json of chatid' do
      expect(response).to have_http_status 200
      expect(json).to eql login_token
    end
  end

  context 'valid email and password is provided' do
    let(:chatid) { SecureRandom.hex }
    let(:login_token) { { 'token' => SecureRandom.hex } }
    let(:password) { '123456789' }

    before do
      user.update!(chatid: chatid, password: password, password_confirmation: password)
    end

    it 'returns successful response with json of chatid' do
      expect(Chat).to receive(:login_token).with(chatid).and_return(login_token)
      post '/chat_auth', params: { email: user.email, password: password }
      expect(response).to have_http_status 200
      expect(json).to eql login_token
    end

    it 'rejects access if password is incorrect' do
      post '/chat_auth', params: { email: user.email, password: 'wrong-password' }
      expect(response).to have_http_status 401
      expect(json['error']).to eql 'Invalid email or password'
    end
  end
end
