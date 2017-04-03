require 'rails_helper'

describe User do
  before(:all) { DatabaseCleaner.start }
  after(:all) { DatabaseCleaner.clean }

  it { should have_one(:api_token) }
  it { should have_many(:lists) }

  describe 'validations' do
    before(:all) do
      @user = create(:user, sf_guard_user_id: rand(1000), email: 'fake@fake.com', username: 'unqiue2')
    end

    it { should validate_presence_of(:default_network_id) }

    it 'validates presence of email' do
      expect(@user.valid?).to be true
      expect(build(:user, sf_guard_user_id: rand(1000), email: nil).valid?).to be false
    end

    it 'validates uniqueness of email' do
      expect(User.new(sf_guard_user_id: rand(1000), email: 'fake@fake.com', username: 'aa', default_network_id: 79).valid?). to be false
      expect(User.new(sf_guard_user_id: rand(1000), email: 'fake2@fake.com', username: 'bb', default_network_id: 79).valid?). to be true
    end

    describe 'sf_guard' do
      subject { build(:user, sf_guard_user_id: rand(1000)) }
      it { should validate_uniqueness_of(:sf_guard_user_id) }
      it { should validate_presence_of(:sf_guard_user_id) }
    end
  end

  describe 'legacy_check_password' do
    before(:all) do
      @sf_user = create(:sf_guard_user, salt: 'SALT', password: Digest::SHA1.hexdigest('SALTPEANUTS'))
      @user = create(:user, username: 'unique', sf_guard_user_id: @sf_user.id)
    end
    it 'returns true for correct password' do
      expect(@user.legacy_check_password('PEANUTS')).to be true
    end

    it 'returns false for incorrect password' do
      expect(@user.legacy_check_password('FAKE_PEANUTS')).to be false
    end
  end

  describe 'create_default_permissions' do
    before do
      @sf_user = create(:sf_guard_user, username: "user#{rand(1000)}")
      @user = create(:user, sf_guard_user_id: @sf_user.id, email: "#{rand(1000)}@fake.com")
    end

    it 'creates contributor permission' do
      expect(@user.has_legacy_permission('contributor')).to be false
      @user.create_default_permissions
      expect(@user.has_legacy_permission('contributor')).to be true
    end

    it 'creates editor permission' do 
      expect(@user.has_legacy_permission('editor')).to be false
      @user.create_default_permissions
      expect(@user.has_legacy_permission('editor')).to be true
    end
  end

  describe 'chat user' do
    describe 'create_chat_account' do
      it 'returns :existing_account if user has chatid' do
        expect(build(:user, chatid: '12345').create_chat_account).to be :existing_account
      end

      it 'creates account' do
        chat = Chat.new
        expect(chat).to receive(:admin_login).once
        expect(chat).to receive(:admin_logout).once
        expect(chat).to receive(:post).and_return('user' => { '_id' => 'mongoid' }, 'success' => true)
        expect(Chat).to receive(:new).and_return(chat)
        user = build(:user)
        expect(user).to receive(:update).with(chatid: 'mongoid')
        user.create_chat_account
      end
    end
  end

  describe '#admin?' do
    context 'is admin' do
      before do
        @sf_user = create(:sf_guard_user)
        @user = create(:user, sf_guard_user_id: @sf_user.id)
        SfGuardUserPermission.create!(permission_id: 1, user_id: @sf_user.id)
      end

      it 'returns true' do
        expect(@user.admin?).to be true
      end
    end

    context 'is not admin' do
      before do
        @sf_user = create(:sf_guard_user)
        @user = create(:user, sf_guard_user_id: @sf_user.id)
      end

      it 'returns true' do
        expect(@user.admin?).to be false
      end
    end
  end
end
