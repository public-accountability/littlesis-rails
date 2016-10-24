require 'rails_helper'

describe User do 
  
  before(:all) do 
    DatabaseCleaner.start
  end

  after(:all) do 
    DatabaseCleaner.clean
  end

  describe 'legacy_check_password' do 
    before(:all) do 
      @sf_user = create(:sf_guard_user, salt: 'SALT', password: Digest::SHA1.hexdigest('SALTPEANUTS'))
      @user = create(:user, sf_guard_user_id: @sf_user.id)
    end
    it 'returns true for correct password' do 
      expect(@user.legacy_check_password('PEANUTS')).to be true
    end

    it 'returns false for incorrect password' do 
      expect(@user.legacy_check_password('FAKE_PEANUTS')).to be false
    end

  end
end
