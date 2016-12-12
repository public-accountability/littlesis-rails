require 'rails_helper' 

describe 'entities/add_relationship.html.erb' do
  

  before(:all) do 
    DatabaseCleaner.start
    @sf_user = build(:sf_guard_user)
    @user = build(:user, sf_guard_user: @sf_user)
    @e = build(:mega_corp_inc, updated_at: Time.now, last_user: @sf_user)
  end

  after(:all) {  DatabaseCleaner.clean } 

  describe 'layout' do 

    before do
      assign(:entity, @e)
      render
    end

    it 'has entity header' do 
      expect(rendered).to have_tag '#entity-header'
    end

    it 'has add relationship title section' do
      expect(rendered).to have_tag 'h2', :text => "Create a new relationship"
      expect(rendered).to have_css "div.col-sm-7 p"
    end

    it 'has search-results-row' do 
      expect(rendered).to have_css "#search-results-row", :count => 1
    end

    it 'has one table' do
      expect(rendered).to have_tag "table", :count => 1
    end

  end
end


