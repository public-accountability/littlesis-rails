require 'rails_helper'

describe User do 
  
  before(:all) { DatabaseCleaner.start }
  after(:all) { DatabaseCleaner.clean }
   
  describe 'validations' do 
    before(:all) do 
      @user = create(:user,  sf_guard_user_id: rand(1000), email: 'fake@fake.com', username: 'unqiue2')
    end

    it { should validate_presence_of(:default_network_id)}

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
end
