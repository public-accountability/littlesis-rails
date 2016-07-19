require 'rails_helper' 

describe 'entities/show.html.erb' do
  describe 'layout' do
    before do
      e = create(:mega_corp_inc)
      assign(:entity, e)
      render
    end

    it 'has correct header' do
      expect(rendered).to have_css('#entity-header')
      expect(rendered).to have_css('#entity-header a', :count => 1)
      expect(rendered).to have_css('#entity-name', :text => "mega corp INC")
      expect(rendered).to have_css('#entity-blurb', :text => "mega corp is having an existential crisis")
    end
    
  end
end
