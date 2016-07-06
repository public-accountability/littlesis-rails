require 'rails_helper'

describe 'lists/index.html.erb' do 
  before do
    @new_list = create(:list)
    @new_list_2 = create(:list, name: 'my interesting list')
    @inc = create(:mega_corp_inc)
    ListEntity.find_or_create_by(list_id: @new_list.id, entity_id: @inc.id)
    ListEntity.find_or_create_by(list_id: @new_list_2.id, entity_id: @inc.id)
    assign(:lists, ListsController.get_lists(params[:page]))
    render
  end
  it 'displays alert with info' do 
    expect(rendered).to have_selector(".alert.alert-info")
  end
  it 'has search box' do 
    expect(rendered).to have_selector("input#list-search")
  end
  it 'has 2 list entries in the table' do 
    expect(rendered).to have_css(".lists_table_name", :count => 2)
  end
end
