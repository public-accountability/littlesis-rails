class ChatController < ApplicationController
  before_action :authenticate_user!, only: [ :chat_auth ]

  # POST littlesis.org/chat_auth
  def chat_auth
    current_user.create_chat_account if current_user.chatid.blank?
    
  end

  # GET /chat_login
  def login
    response.headers.delete('X-Frame-Options')
  end
  

  private

  def mongo_client
    # Mongo::Client.new([APP_CONFIG['rocket_chat_mongo_url']], :database => 'rocketchat')  
  end

end

