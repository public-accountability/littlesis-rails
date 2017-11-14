require 'rails_helper'

describe HelpPagesController, type: :controller do
  it { should route(:get, '/help').to(action: :index) }
end
