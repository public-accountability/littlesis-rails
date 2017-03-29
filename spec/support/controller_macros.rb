module ControllerMacros
  def login_admin
    before(:each) do
      @request.env["devise.mapping"] = Devise.mappings[:admin]
      # sign_in FactoryGirl.create(:admin) # Using factory girl as an example
      sf_user = FactoryGirl.create(:sf_guard_user)
      user = FactoryGirl.create(:user, sf_guard_user_id: sf_user.id)
      SfGuardUserPermission.create!(permission_id: 1, user_id: sf_user.id)
      sign_in user
    end
  end

  def login_user
    before(:each) do
      @request.env["devise.mapping"] = Devise.mappings[:user]
      sf_user = FactoryGirl.create(:sf_guard_user)
      user = FactoryGirl.create(:user, sf_guard_user_id: sf_user.id)
      SfGuardUserPermission.create!(permission_id: 2, user_id: sf_user.id)
      SfGuardUserPermission.create!(permission_id: 3, user_id: sf_user.id)
      SfGuardUserPermission.create!(permission_id: 5, user_id: sf_user.id)
      SfGuardUserPermission.create!(permission_id: 6, user_id: sf_user.id)
      SfGuardUserPermission.create!(permission_id: 7, user_id: sf_user.id)
      SfGuardUserPermission.create!(permission_id: 8, user_id: sf_user.id)
      SfGuardUserPermission.create!(permission_id: 9, user_id: sf_user.id)
      # user.confirm! # or set a confirmed_at inside the factory. Only necessary if you are using the "confirmable" module
      sign_in user
    end
  end

  def login_basic_user
    before(:each) do
      @request.env["devise.mapping"] = Devise.mappings[:user]
      sf_user = FactoryGirl.create(:sf_guard_user)
      user = FactoryGirl.create(:user, sf_guard_user_id: sf_user.id)
      SfGuardUserPermission.create!(permission_id: 2, user_id: sf_user.id)
      SfGuardUserPermission.create!(permission_id: 3, user_id: sf_user.id)
      SfGuardUserPermission.create!(permission_id: 5, user_id: sf_user.id)
      sign_in user
    end
  end
end
