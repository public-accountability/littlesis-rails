require 'rails_helper'

describe 'Chat' do
  let(:user) { create_really_basic_user }

  context 'user is not signed in' do
    before { post "/chat_auth" }

    it 'request is unauthorized' do
      expect(response).to have_http_status 401
    end
  end

  context 'user is restricted' do
    let(:user) { create_restricted_user }
    before do
      login_as(user, :scope => :user)
      post "/chat_auth"
    end
    after { logout(:user) }
    denies_access
  end

  context 'user in signed in' do
    let(:chatid) { SecureRandom.hex }
    let(:login_token) { { 'token' => SecureRandom.hex } }

    before do
      expect(Chat).to receive(:login_token).with(chatid).and_return(login_token)
      user.update!(chatid: chatid)
      login_as(user, :scope => :user)
      post "/chat_auth"
    end
    after { logout(:user) }

    it 'returns successful response with json of chatid' do
      expect(response).to have_http_status 200
      expect(json).to eql login_token
    end
  end
end
