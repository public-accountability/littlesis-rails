# frozen_string_literal: true

module ControllerMacros
  def login_admin
    before(:each) do
      @request.env["devise.mapping"] = Devise.mappings[:admin]
      sign_in RspecExampleHelpers.create_admin_user
    end
  end

  def login_user(abilities = [:edit])
    before(:each) do
      @request.env["devise.mapping"] = Devise.mappings[:user]
      user = FactoryBot.create(:user)
      create(:user_profile, user: user)
      user.add_ability(*abilities)
      sign_in(user)
    end
  end

  def login_basic_user
    before(:each) do
      @request.env["devise.mapping"] = Devise.mappings[:user]
      sign_in RspecExampleHelpers.create_basic_user
    end
  end

  def login_restricted_user
    before(:each) do
      @request.env["devise.mapping"] = Devise.mappings[:user]
      sign_in RspecExampleHelpers.create_restricted_user
    end
  end  

  def login_user_without_permissions
    before(:each) do
      @request.env["devise.mapping"] = Devise.mappings[:user]
      user = FactoryBot.create(:user)
      create(:user_profile, user: user)
      sign_in user
    end
  end
end
