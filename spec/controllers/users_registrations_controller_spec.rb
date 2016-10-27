require 'rails_helper'

describe Users::RegistrationsController, type: :controller do
  # include Devise::Test::ControllerHelpers
  before(:all) { DatabaseCleaner.start }
  after(:all)  { DatabaseCleaner.clean }
  
  describe 'GET new' do 
    before do
      # reason for this: https://github.com/plataformatec/devise/issues/608
      request.env['devise.mapping'] = Devise.mappings[:user] 
      get :new
    end
    
    it 'request is successful' do 
      expect(response).to be_success
    end
    
  end 

  def user_data
    { 
        "email"=>"test@testing.com", 
        "password"=>"12345678", 
        "password_confirmation"=>"12345678",
        "username"=>"testuser",
        "default_network_id"=>"79",
        "newsletter"=>"0",
        "sf_guard_user_profile"=>{"name_first"=>"firstname", "name_last"=>"lastname"}
      }
  end

  def post_create(data)
    post :create, {"user"=> data}
  end

  describe 'POST create' do 
    before(:each) do 
      request.env['devise.mapping'] = Devise.mappings[:user] 
    end

    it 'creates user' do 
      user_count = User.count
      post_create user_data
      expect(User.count).to eql ( user_count + 1 )
    end

    it 'creates sf_user' do 
      sf_guard_user_count = SfGuardUser.count
      post_create user_data
      expect(SfGuardUser.count).to eql (sf_guard_user_count + 1 )
    end

    it 'creates sf_user_profile' do 
      sf_guard_user_profile_count = SfGuardUserProfile.count
      post_create user_data
      expect(SfGuardUserProfile.count).to eql (sf_guard_user_profile_count + 1 )
    end

    it 'works if user says yes to newsletter' do 
      post_create user_data.merge({"newsletter"=>"1"})
      expect(User.last.newsletter).to be true
    end
    
    it 'works if user says no to newsletter' do 
      post_create user_data
      expect(User.last.newsletter).to be false
    end

  end

end
