# frozen_string_literal: true


describe Users::RegistrationsController, type: :controller do
  let(:user_data) do
    {
      'email' => 'test@testing.com',
      'password' => '12345678',
      'password_confirmation' => '12345678',
      'username' => 'testuser',
      'default_network_id' => '79',
      'newsletter' => '0',
      'user_profile_attributes' => {
        'name_first' => 'firstname',
        'name_last' => 'lastname',
        'reason' => 'doing research'
      }
    }
  end

  let(:invalid_user_data) do
    user_data.deep_merge('user_profile_attributes' => {
                           'name_first' => 'firstname',
                           'name_last' => 'lastname',
                           'reason' => 'onewordanswer'
                         })
  end

  describe 'Routes' do
    it { is_expected.to route(:get, '/join').to(action: :new) }
    it { is_expected.to route(:post, '/join').to(action: :create) }
    it { is_expected.to route(:get, '/users/edit').to(action: :edit) }
    it { is_expected.to route(:put, '/users').to(action: :update) }
    it { is_expected.to route(:delete, '/users').to(action: :destroy) }
    it { is_expected.to route(:post, '/users/api_token').to(action: :api_token) }
  end

  describe 'GET new' do
    before do
      # reason for this: https://github.com/plataformatec/devise/issues/608
      request.env['devise.mapping'] = Devise.mappings[:user]
      get :new
    end

    it { is_expected.to respond_with(:success) }
  end

  def post_create(data)
    post :create, params: { 'user' => data }
  end

  describe 'Creating new users' do
    before do
      request.env['devise.mapping'] = Devise.mappings[:user]
      allow(controller).to receive(:verify_math_captcha).and_return(true)
    end

    context 'when submitting with valid data' do
      it 'creates user' do
        expect { post_create(user_data) }.to change(User, :count).by(1)
      end

      it 'creates the user profile' do
        expect { post_create(user_data) }.to change(UserProfile, :count).by(1)
      end

      it 'records answer if user says yes to newsletter' do
        post_create user_data.merge('newsletter' => '1')
        expect(User.last.newsletter).to be true
      end

      it 'records answer if users says no to newsletter' do
        post_create user_data
        expect(User.last.newsletter).to be false
      end
    end

    context 'when submitting with invalid user data' do
      describe 'user submits answer to the field reason with less than 2 words' do
        it 'does not create a user' do
          expect { post_create(invalid_user_data) }.not_to change(User, :count)
        end
      end
    end
  end

  describe '#api_token' do
    login_user

    before do
      request.env['devise.mapping'] = Devise.mappings[:user]
    end

    def post_api_token(action)
      post :api_token, params: { 'api' => action }
    end

    describe 'generating api tokens' do
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

    describe 'resting api token' do
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
        expect(response).to have_http_status :not_acceptable
      end
    end
  end
end
