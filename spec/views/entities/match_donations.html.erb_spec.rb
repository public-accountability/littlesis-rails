require 'rails_helper' 


describe 'entities/match_donations.html.erb' do
  
  before(:all) do 
    DatabaseCleaner.start
    @sf_user = create(:sf_guard_user)
    @user = create(:user, sf_guard_user_id: @sf_user.id)
    @e = build(:mega_corp_inc, updated_at: Time.now, last_user: @sf_user)
  end

  after(:all) do 
    DatabaseCleaner.clean
  end

  describe 'layout' do 
    
    before do 
      puts 'render'
      assign(:entity, @e)
      render
    end
    
    it 'has header' do 
      expect(rendered).to have_css '#entity-header'
    end
    
    it 'has actions' do 
      expect(rendered).to have_css '#entity-edited-history'
      expect(rendered).to have_css '#entity-actions a', :count => 3
    end
  
  end
end


