feature "Browsing an entity's references", type: :feature, js: true do
  let(:entity) { create(:entity_person) }
  let!(:references) { create_list(:entity_ref, 20, referenceable: entity) }

  before do
    # Calls here to the standard entity_path work but never complete, leading
    # to test failures
    visit "/entities/#{entity.id}"
  end

  scenario 'browsing references in the sidebar' do
    expect(page).to have_css('.sidebar-source-links-document-count', text: "20 documents ::")

    # Check we have a list of 10 sources visible
    expect(page).to have_css('.sidebar-source-links-list a', count: 10)
    first_source = first('.sidebar-source-links-list a').text
    expect(references.map { |r| r.document.name }).to include first_source

    # Click "view more"
    find('.sidebar-source-links .bi-arrow-right').click

    # Check we now have a different list of 10
    expect(page).to have_css('.sidebar-source-links-list a', count: 10)
    new_first_source = first('.sidebar-source-links-list a').text
    expect(new_first_source).not_to eq first_source

    # Click "back" to view the first list
    find('.sidebar-source-links .bi-arrow-left').click
    expect(page).to have_css('.sidebar-source-links-list a', count: 10)
    new_first_source = first('.sidebar-source-links-list a').text
    expect(new_first_source).to eq first_source
  end
end
