require 'rails_helper'

feature 'list page', type: :feature do
  let(:document_attributes) { attributes_for(:document) }
  let(:list) do
    list = create(:list)
    ListEntity.create!(list_id: list.id, entity_id: create(:entity_person).id)
    list.add_reference(document_attributes)
    list
  end

  scenario 'visiting the list page' do
    visit list_path(list)
    successfully_visits_page(list_path(List.last) + '/members')
    expect(page.find('#list-name')).to have_text list.name
    expect(page).not_to have_selector '#list-tags-container'
  end

  scenario 'navigating to the sources tab' do
    visit list_path(list)
    click_on 'Sources'
    successfully_visits_page(list_path(List.last) + '/references')
    page_has_selector '#list-sources'
    expect(page).to have_link document_attributes[:name], href: document_attributes[:url]
  end

  feature 'list page with tags' do
    let(:tag) { create(:tag) }
    let!(:tags) { list.add_tag(tag.id) }

    scenario 'tags are visable on the page' do
      visit list_path(list)
      expect(page).to have_selector '#list-tags-container'
      expect(page).to have_selector '#tags-list li', text: tag.name
    end
  end
end
