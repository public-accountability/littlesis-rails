# frozen_string_literal: true

class ChatController < ApplicationController
  layout 'simple'
  skip_before_action :verify_authenticity_token, only: [:chat_auth]

  # POST littlesis.org/chat_auth
  def chat_auth
    cors_headers

    if user_signed_in?
      return render_invalid_auth :restricted if current_user.restricted?
      return render_chat_json(current_user)
    end

    unless params.key?('password') && params.key?('email')
      return render_invalid_auth :missing
    end

    user = User.find_by(email: params[:email].downcase)

    if user&.valid_password?(params[:password])
      if user.restricted?
        render_invalid_auth :restricted
      else
        render_chat_json(user)
      end
    else
      render_invalid_auth :invalid
    end
  end

  # GET /chat_login
  def login
    response.headers.delete('X-Frame-Options')
  end

  private

  def cors_headers
    if Rails.env.production?
      allow_host = 'https://chat.littlesis.org'
    else
      allow_host = 'http://localhost:3000'
    end
    response.headers['Access-Control-Allow-Origin'] = allow_host
    response.headers['Access-Control-Allow-Methods'] = 'POST, PUT, DELETE, GET, OPTIONS'
    response.headers['Access-Control-Allow-Credentials'] = 'true'
    response.headers['Access-Control-Request-Method'] = '*'
    response.headers['Access-Control-Allow-Headers'] = 'Origin, X-Requested-With, Content-Type, Accept, Authorization'
  end

  def render_chat_json(user)
    # create chat account if needed
    user.create_chat_account if user.chatid.blank?
    # Set iframe token and send json back
    render json: Chat.login_token(user.chatid)
  end

  def render_invalid_auth(reason)
    render json: { error: invalid_auth_msg(reason) }, status: :unauthorized
  end

  def invalid_auth_msg(reason)
    case reason
    when :invalid
      'Invalid email or password'
    when :missing
      'Missing email address or password'
    when :restricted
      'Your account has been restricted'
    else
      'Sign-in failed'
    end
  end
end
