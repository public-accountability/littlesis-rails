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
    it { should route(:post, '/users/api_token').to(action: :api_token) }
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

  describe '#api_token' do
    login_user

    before do
      request.env['devise.mapping'] = Devise.mappings[:user]
    end

    def post_api_token(action)
      post :api_token, 'api' => action
    end

    context 'generating api tokens' do
      it 'generates api_token' do
        expect(controller.current_user.api_token.present?).to be false
        expect { post_api_token('generate') }.to change { ApiToken.count }.by(1)
        expect(controller.current_user.api_token.present?).to be true
        # doesn't generate one if user already has one
        expect { post_api_token('generate') }.not_to change { ApiToken.count }
      end

      it 'renders template edit' do
        post_api_token('generate')
        expect(response).to render_template 'edit'
      end
    end

    context 'resting api token' do
      before do
        ApiToken.record_timestamps = false
        controller.current_user.create_api_token!(created_at: 1.year.ago, updated_at: 1.year.ago)
        ApiToken.record_timestamps = true
      end

      it 'resets api token' do
        original_token = controller.current_user.api_token.token
        post_api_token('reset')
        expect(controller.current_user.api_token.updated_at).to be > 1.day.ago
        expect(controller.current_user.api_token.token).not_to eql original_token
      end

      it 'renders template edit' do
        post_api_token('reset')
        expect(response).to render_template 'edit'
      end

      it 'responds with unacceptable if attempt to reset more than once in a 24 hour period' do
        controller.current_user.api_token.touch
        post_api_token('reset')
        expect(response).to have_http_status 406
      end
    end
  end
end
