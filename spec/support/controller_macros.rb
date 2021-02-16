# frozen_string_literal: true

module ControllerMacros
  def login_admin
    before do
      @request.env["devise.mapping"] = Devise.mappings[:admin]
      sign_in RspecHelpers::ExampleMacros.create_admin_user
    end
  end

  def login_user(abilities = [:edit])
    before do
      @request.env["devise.mapping"] = Devise.mappings[:user]
      user = RspecHelpers::ExampleMacros.create_basic_user
      create(:user_profile, user: user)
      user.add_ability(*abilities)
      sign_in(user)
    end
  end

  def login_basic_user
    before do
      @request.env["devise.mapping"] = Devise.mappings[:user]
      sign_in RspecHelpers::ExampleMacros.create_basic_user
    end
  end

  def login_restricted_user
    before do
      @request.env["devise.mapping"] = Devise.mappings[:user]
      sign_in RspecHelpers::ExampleMacros.create_restricted_user
    end
  end

  def login_user_without_permissions
    before do
      @request.env["devise.mapping"] = Devise.mappings[:user]
      user = RspecHelpers::ExampleMacros.create_basic_user
      user.remove_ability(:edit)
      sign_in user
    end
  end
end
