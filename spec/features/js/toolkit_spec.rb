feature 'Editable Toolkit Pages' do
  let(:admin) { create_admin_user }
  let(:toolkit_page) { create(:toolkit_page) }
  let(:page_name) { Faker::Creature::Cat.name }
  let(:page_title) { Faker::Creature::Cat.breed }

  scenario 'visting the toolkit index' do
    visit toolkit_path
    expect(page.status_code).to eq 200
    page_has_selector 'h2', text: 'Map the Power Toolkit'
  end

  scenario 'visting a toolkit page' do
    visit "/toolkit/#{toolkit_page.name}"
    expect(page.status_code).to eq 200
    page_has_selector 'h1', text: 'Toolkit Page'
    page_has_selector 'h2', text: 'Content'
    expect(page).to have_title 'a toolkit page - LittleSis'
  end

  context 'with an admin account', js: true do
    before { login_as(admin, scope: :user) }

    after { logout(admin) }

    scenario 'Editing the toolkit page' do
      visit "/toolkit/#{toolkit_page.name}/edit"
      page_has_selector 'h1', text: "Editing: #{toolkit_page.name}"
      page_has_selector "form\#edit_toolkit_page_#{toolkit_page.id}"

      find(:css, '#toolkit_page_content').click.set('new content')
      click_button 'Update'

      expect(page).to have_text 'new content'
    end

    scenario 'Creating a new toolkit page' do
      original_page_count = ToolkitPage.count
      visit "/toolkit/new"
      page_has_selector 'h1', text: "Create a new toolkit page"
      page_has_selector 'form#new_toolkit_page'

      fill_in 'toolkit_page_name', :with => page_name
      fill_in 'toolkit_page_title', :with => page_title
      click_button 'submit'

      expect(ToolkitPage.count).to eql(original_page_count + 1)

      last_page = ToolkitPage.last
      visit "/toolkit/#{last_page.name}/edit"
      page_has_selector 'h1', text: "Editing: #{last_page.name}"
    end
  end
end
