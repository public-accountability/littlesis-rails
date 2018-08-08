require 'rails_helper'

describe 'Chat' do
  let(:mongo_id) { rand(36**15).to_s(36) }
  let(:chat) { Chat.new }

  describe 'create user' do
    let(:user) { create_really_basic_user }

    let(:payload) do
      hash_including('email' => user.email,
                     'name' => user.username,
                     'username' => user.username,
                     'verified' => true)
    end

    before do
      chat.instance_variable_set(:@admin_token, 'admin_token')
      chat.instance_variable_set(:@admin_id, 'admin_id')
      expect(chat).to receive(:post).once
                        .with('/api/v1/users.create', payload, kind_of(Hash))
                        .and_return(create_user_response)
    end

    context 'valid request' do
      let(:create_user_response) do
        { 'status' => 'success',
          'user' => { '_id' => mongo_id } }
      end

      it 'updates user with mongo chat id' do
        expect { chat.create_user(user) }
          .to change { user.reload.chatid }.from(nil).to(mongo_id)
      end

      context 'invalid request' do
        let(:create_user_response) do
          { 'status' => 'error' }
        end

        it 'does not update the user' do
          expect(user).not_to receive(:update!)
          expect { chat.create_user(user) }
            .to raise_error(Chat::RocketChatApiRequestFailedError)
        end
      end
    end
  end

  describe 'login_token' do
    let(:authToken) { SecureRandom.hex }
    before do
      expect(chat).to receive(:post).once
                        .with('/api/v1/users.createToken', { userId: mongo_id }, kind_of(Hash))
                        .and_return({ 'data' => { 'authToken' => authToken },
                                      'status' => 'success' })
    end

    it 'returns hash with token' do
      expect(chat.login_token(mongo_id)).to eql({ 'loginToken' => authToken })
    end
  end
end

