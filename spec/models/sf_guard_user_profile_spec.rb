require 'rails_helper'

describe SfGuardUserProfile do
  describe 'validations'do
    before(:all) do
      SfGuardUser.where('id <> 1').destroy_all
      @sf_guard_user = create(:sf_guard_user)
    end

    after(:all) do
      SfGuardUser.where('id <> 1').destroy_all
    end

    subject { build(:sf_guard_user_profile, user_id: @sf_guard_user.id)  }
    it { should validate_presence_of(:email) }
    it { should validate_uniqueness_of(:email).case_insensitive }
    it { should validate_presence_of(:name_first) }
    it { should validate_presence_of(:home_network_id) }    
  end
end
