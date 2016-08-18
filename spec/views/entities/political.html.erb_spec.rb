require 'rails_helper' 

describe 'entities/political.html.erb' do
  
  before(:all) do 
    DatabaseCleaner.start
    @sf_user = create(:sf_guard_user, username: 'X')
    @user = create(:user, sf_guard_user_id: @sf_user.id)
    @e = build(:mega_corp_inc, updated_at: Time.now, last_user: @sf_user)
  end

  after(:all) do 
    DatabaseCleaner.clean
  end

  describe 'layout' do 

    before do
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

    it 'has tabs' do 
      expect(rendered).to have_css '.button-tabs span a', :count => 5
    end

    it 'has active Political tab' do 
      expect(rendered).to have_css '.button-tabs span.active a', :text => 'Political', :count => 1
    end

  end
end


