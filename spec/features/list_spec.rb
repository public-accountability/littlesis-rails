require 'rails_helper'

feature 'list page', type: :feature do
  let(:document_attributes) { attributes_for(:document) }
  let(:list) do
    list = create(:list)
    ListEntity.create!(list_id: list.id, entity_id: create(:entity_person).id)
    list.add_reference(document_attributes)
    list
  end

  before { visit list_path(list) }

  scenario 'visiting the list page' do
    successfully_visits_page(list_path(List.last) + '/members')
    expect(page.find('#list-name')).to have_text list.name
  end

  scenario 'navigating to the sources tab' do
    click_on 'Sources'
    successfully_visits_page(list_path(List.last) + '/references')
    page_has_selector '#list-sources'
    expect(page).to have_link document_attributes[:name], href: document_attributes[:url]
  end
  
end
