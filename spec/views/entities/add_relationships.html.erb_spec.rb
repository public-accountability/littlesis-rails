require 'rails_helper' 

describe 'entities/add_relationship.html.erb' do
  

  before(:all) do 
    DatabaseCleaner.start
    @sf_user = build(:sf_guard_user)
    @user = build(:user, sf_guard_user: @sf_user)
    @e = build(:mega_corp_inc, updated_at: Time.now, last_user: @sf_user, id: rand(100) )
  end

  after(:all) {  DatabaseCleaner.clean } 

  describe 'layout' do 

    before do
      assign(:entity, @e)
      render
    end

    it 'has entity-info div' do
      expect(rendered).to have_css 'div#entity-info'
      expect(rendered).to have_css "div#entity-info[data-entitytype='Org']"
      expect(rendered).to have_css "div#entity-info[data-entityid='#{@e.id}']"
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
    
    it 'has one image' do
      expect(rendered).to have_tag "img", :count => 1
    end

    specify { css '#existing-reference-container' }
    specify { css '#new-reference-container' }
    specify { css '#similar-relationships' }
    specify { css '#create-relationship-btn' }

    it { should render_template(partial: '_header') }
    it { should render_template(partial: '_explain_categories_modal') }
    it { should render_template(partial: '_new_entity_form') }
  end
end


