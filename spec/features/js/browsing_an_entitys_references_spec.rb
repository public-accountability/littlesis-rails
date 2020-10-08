feature "Browsing an entity's references", type: :feature, js: true do
  let(:entity) { create(:entity_person) }
  let!(:references) { create_list(:entity_ref, 20, referenceable: entity) }

  before do
    # Calls here to the standard entity_path work but never complete, leading
    # to test failures
    visit "/entities/#{entity.id}"
  end

  scenario 'browsing references in the sidebar' do
    expect(page).to have_css('em.link-count', text: 20)

    # Check we have a list of 10 sources visible
    expect(page).to have_css('#source-links-container a', count: 10)
    first_source = first('#source-links-container a').text
    expect(references.map { |r| r.document.name }).to include first_source
    expect(page).to have_css('.link-arrow-text', text: 'view more')

    # Click "view more"
    find('#source-links-right-arrow').click

    # Check we now have a different list of 10
    expect(page).to have_css('#source-links-container a', count: 10)
    new_first_source = first('#source-links-container a').text
    expect(new_first_source).not_to eq first_source

    # Click "back" to view the first list
    find('#source-links-left-arrow').click
    new_first_source = first('#source-links-container a').text
    expect(new_first_source).to eq first_source
  end
end
