require 'rails_helper'

describe HelpPagesController, type: :controller do
  it { should route(:get, '/help').to(action: :index) }
  it { should route(:get, '/help/new').to(action: :new) }
  it { should route(:get, '/help/pages').to(action: :pages) }
  it { should route(:post, '/help').to(action: :create) }
  it { should route(:get, '/help/my_help_page').to(action: :display, page_name: 'my_help_page') }
  it { should route(:get, '/help/my_help_page/edit').to(action: :edit, page_name: 'my_help_page') }
  it { should route(:patch, '/help/123').to(action: :update, id: '123') }
end
