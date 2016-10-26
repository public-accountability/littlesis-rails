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

  describe 'POST create' do 
    before(:each) do 
      request.env['devise.mapping'] = Devise.mappings[:user] 
      
    end
    
    it 'creates user, sf_user, sf_user_profile' do
      @user_count = User.count
      @sf_guard_user_count = SfGuardUser.count
      @sf_guard_user_profile_count = SfGuardUserProfile.count
      post :create, { 
             "user"=> {
               "email"=>"test@testing.com", 
               "password"=>"12345678", 
               "password_confirmation"=>"12345678",
               "username"=>"testuser",
               "default_network_id"=>"79",
               "sf_guard_user_profile"=>{"name_first"=>"firstname", "name_last"=>"lastname"}
             }}
      expect(User.count).to eql (@user_count + 1 )
      expect(SfGuardUser.count).to eql (@sf_guard_user_count + 1 )
      expect(SfGuardUserProfile.count).to eql (@sf_guard_user_profile_count + 1 )
    end

  end
  

end
