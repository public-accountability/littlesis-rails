require 'rails_helper'

describe 'lists/new.html.erb' do 
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
  
  it 'contains 3 checkboxes' do
    expect(rendered).to have_selector('input[type=checkbox]', :count => 3 )
  end

  it 'contains 1 submit button' do
    expect(rendered).to have_selector('input[type=submit]', :count => 1 )
  end
  
end



