require 'rails_helper'

describe 'lists/new.html.erb' do 
  describe 'layout with no error' do 
    before do
      assign(:list, List.new)
      render
    end

    it 'contains one form' do
      expect(rendered).to have_selector('form', :count => 1 )
    end

    it 'contains 3 text inputs' do
      expect(rendered).to have_selector('input[type=text]', :count => 3 )
    end

    it 'contains 1 text_area' do
      expect(rendered).to have_selector('textarea', :count => 1 )
    end
    
    it 'contains 4 checkboxes' do
      expect(rendered).to have_selector('input[type=checkbox]', :count => 4 )
    end

    it 'contains 1 submit button' do
      expect(rendered).to have_selector('input[type=submit]', :count => 1 )
    end

    it 'contains 1 link' do
      expect(rendered).to have_selector('a', :count => 1 )
    end

    it 'contains no error message' do
      expect(rendered).not_to have_selector('#error_explanation')
    end
  end
  
  describe 'layout with errors' do 
    it 'has alert when there is an error' do 
      l = List.new
      l.save
      assign(:list, l)
      render
      expect(rendered).to have_selector('#error_explanation')
    end
  end
end
