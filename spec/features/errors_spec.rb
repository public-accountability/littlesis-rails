feature "asking for things that don't exist", type: :feature do
  let!(:entity) { create(:entity_person) }

  scenario 'visiting an existing entity' do
    expect { visit entity_path(entity) }.not_to raise_error
  end

  scenario 'returns a 404 for non-HTML formats' do
    expect { visit '/wombat.coffin' }.not_to raise_error
    expect(page).to have_http_status 404
  end

  scenario "returns a 404 and custom error page for bad URLs with HTML format" do
    expect { visit '/wombat.html' }.not_to raise_error
    expect(page).to have_http_status 404
    expect(body).to have_text('Oops! Page Not Found')
  end
end
