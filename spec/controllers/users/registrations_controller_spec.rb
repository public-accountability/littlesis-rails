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
        'name' => 'firstname lastname',
        'reason' => 'doing research'
      }
    }
  end

  let(:math_captcha_params) do
    {
      math_captcha_first: 1,
      math_captcha_second: 2,
      math_captcha_operation: '+',
      math_captcha_answer: 3
    }
  end

  let(:invalid_user_data) do
    user_data.merge('username' => '1')
  end

  describe 'Routes' do
    it { is_expected.to route(:get, '/join').to(action: :new) }
    it { is_expected.to route(:post, '/join').to(action: :create) }
    it { is_expected.to route(:get, '/settings').to(action: :edit) }
    it { is_expected.to route(:put, '/users').to(action: :update) }
    it { is_expected.to route(:delete, '/users').to(action: :destroy) }
    it { is_expected.to route(:put, '/users/settings').to(action: :update_settings) }
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
    post :create, params: { user: data, math_captcha: math_captcha_params }
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
end
