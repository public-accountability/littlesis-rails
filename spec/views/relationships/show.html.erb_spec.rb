require 'rails_helper'

RSpec.describe "relationships/show.html.erb", type: :view do
  before(:all) do
    DatabaseCleaner.start
  end

  after(:all) do 
    DatabaseCleaner.clean
  end

  describe 'layout' do 

    before do
      render
    end

  end
  
end
