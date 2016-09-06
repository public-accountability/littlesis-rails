require 'rails_helper'

RSpec.describe "relationships/show.html.erb", type: :view do
  before(:all) do
    # DatabaseCleaner.start
    @sf_user = build(:sf_guard_user)
    @user = build(:user)
    @sf_user.user = @user
    @rel = build(:relationship, category_id: 1, description1: 'boss', id: 123, updated_at: Time.now)
    @rel.position = build(:position, is_board: false)
    @rel.last_user = @sf_user
  end

  after(:all) do 
    # DatabaseCleaner.clean
  end

  describe 'layout' do 

    before do
      assign(:relationship, @rel)
      render
    end

    it 'has title' do 
      expect(rendered).to have_css 'h1', :text => "Position: Human Being, mega corp LLC"
    end
    
    describe 'actions' do 
      
      
    end
    
    
  end
  
end
