class ChatController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:chat_auth]

  # POST littlesis.org/chat_auth
  def chat_auth
    cors_headers
    # return status code 401 if the user is not logged in
    return head :unauthorized unless user_signed_in?
    # return status code 403 if the user is restricted
    return head :forbidden if current_user.restricted?
    # create chat account if needed
    current_user.create_chat_account if current_user.chatid.blank?
    # Set iframe token and send json back
    render json: Chat.login_token(current_user.chatid)
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
end
