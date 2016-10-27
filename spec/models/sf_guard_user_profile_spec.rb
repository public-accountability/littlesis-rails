require 'rails_helper'

describe SfGuardUserProfile do 
  before(:all) { DatabaseCleaner.start }
  after(:all) { DatabaseCleaner.clean }

  describe 'validations'do 
    before(:all) do 
      @sf_guard_user = create(:sf_guard_user)
    end
    subject { build(:sf_guard_user_profile, user_id: @sf_guard_user.id)  }
    it { should validate_presence_of(:email) }
    it { should validate_uniqueness_of(:email).case_insensitive }
    it { should validate_presence_of(:name_first) }
    it { should validate_presence_of(:home_network_id) }    
  end
end
