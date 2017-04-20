require 'rails_helper'

describe PagesController, type: :controller do
  it { should route(:get, '/oligrapher').to(action: :oligrapher_splash) }
  it { should route(:get, '/partypolitics').to(action: :partypolitics) }
end
