require 'rails_helper' 


describe 'entities/political.html.erb' do
  
  before do 
    @user = build(:user)
    @e = build(:mega_corp_inc, updated_at: Time.now)
    assign(:entity, @e)
    assign(:last_user, @user) 
    render
  end

  describe 'layout' do 
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


