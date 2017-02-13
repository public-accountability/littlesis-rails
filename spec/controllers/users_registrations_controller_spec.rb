require 'rails_helper'

describe Users::RegistrationsController, type: :controller do
  # include Devise::Test::ControllerHelpers
  before(:all) { DatabaseCleaner.start }
  after(:all)  { DatabaseCleaner.clean }

  describe 'Routes' do
    it { should route(:get, '/join').to(action: :new) }
    it { should route(:post, '/join').to(action: :create) }
    it { should route(:get, '/users/edit').to(action: :edit) }
    it { should route(:put, '/users').to(action: :update) }
    it { should route(:delete, '/users').to(action: :destroy) }
  end

  describe 'GET new' do
    before do
      # reason for this: https://github.com/plataformatec/devise/issues/608
      request.env['devise.mapping'] = Devise.mappings[:user]
      get :new
    end
    it { should respond_with(:success) }
  end

  def user_data
    {
      'email' => 'test@testing.com',
      'password' => '12345678',
      'password_confirmation' => '12345678',
      'username' => 'testuser',
      'default_network_id' => '79',
      'newsletter' => '0',
      'sf_guard_user_profile' => {
        'name_first' => 'firstname',
        'name_last' => 'lastname',
        'reason' => 'research'
      }
    }
  end

  def post_create(data)
    post :create, 'user' => data
  end

  describe 'POST create' do
    before(:each) do
      request.env['devise.mapping'] = Devise.mappings[:user]
    end

    it 'creates user' do
      expect { post_create(user_data) }.to change { User.count }.by(1)
    end

    it 'creates sf_user' do
      expect { post_create(user_data) }.to change { SfGuardUser.count }.by(1)
    end

    it 'creates sf_user_profile' do
      expect { post_create(user_data) }.to change { SfGuardUserProfile.count }.by(1)
    end

    it 'populates SfGuardProfile with correct info' do
      post_create user_data
      profile = SfGuardUserProfile.last
      expect(profile.name_last).to eql 'lastname'
      expect(profile.name_first).to eql 'firstname'
      expect(profile.reason).to eql 'research'
    end

    it 'records answer if user says yes to newsletter' do
      post_create user_data.merge('newsletter' => '1')
      expect(User.last.newsletter).to be true
    end

    it 'reocrds answer if users says no to newsletter' do
      post_create user_data
      expect(User.last.newsletter).to be false
    end
  end
end
