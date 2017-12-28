require 'rails_helper'

describe ChatController, type: :controller do
  it { should route(:post, '/chat_auth').to(action: :chat_auth) }
  it { should route(:get, '/chat_login').to(action: :login) }
end
