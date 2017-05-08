require 'rails_helper'

describe PagesController, type: :controller do
  it { should route(:get, '/oligrapher').to(action: :oligrapher_splash) }
  it { should route(:get, '/partypolitics').to(action: :partypolitics) }
  it { should route(:get, '/about').to(action: :display, page: 'about') }
  it { should_not route(:post, '/about').to(action: :display, page: 'about') }
  it { should route(:get, '/features').to(action: :display, page: 'features') }
  it { should_not route(:get, '/bad_page').to(action: :display) }

  it 'has MARKDOWN constant' do
    expect(ToolkitController::MARKDOWN).to be_a(Redcarpet::Markdown)
  end
end
