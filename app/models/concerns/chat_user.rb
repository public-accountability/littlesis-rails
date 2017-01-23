module ChatUser
  extend ActiveSupport::Concern
  # included do
  # end
  #module ClassMethods
  # end

  def create_chat_account
    return :existing_account unless chatid.blank?
    chat = Chat.new
    chat.admin_login
    chat.create_user(self)
    chat.admin_logout
  end
end
