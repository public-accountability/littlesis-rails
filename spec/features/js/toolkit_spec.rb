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
    visit toolkit_display_path(toolkit_page.name)
    expect(page.status_code).to eq 200
    page_has_selector 'h1', text: 'Toolkit Page'
    page_has_selector 'h2', text: 'Content'
    expect(page).to have_title 'a toolkit page - LittleSis'
  end

  context 'with an admin account', js: true do
    before { login_as(admin, scope: :user) }

    after { logout(admin) }

    context 'with an existing toolkit page' do
      let(:toolkit_page) { create(:toolkit_page, content: '') }

      scenario 'Editing the toolkit page' do
        visit toolkit_edit_path(toolkit_page.name)

        page_has_selector 'h1', text: "Editing: #{toolkit_page.name}"
        page_has_selector "form\#edit_toolkit_page_#{toolkit_page.id}"

        content_field = find('#toolkit_page_content')
        find(:css, '.trix-button--icon-heading-1').click
        content_field.send_keys 'I Am the Main Title', :enter
        find(:css, '.trix-button--icon-heading-2').click
        content_field.send_keys 'I Am a Subhead', :enter

        click_button 'Update'

        visit toolkit_display_path(toolkit_page.name)
        page_has_selector 'h1', text: 'I Am the Main Title'
        page_has_selector 'h2', text: 'I Am a Subhead'
      end
    end

    scenario 'Creating a new toolkit page' do
      original_page_count = ToolkitPage.count
      visit toolkit_new_path
      page_has_selector 'h1', text: "Create a new toolkit page"
      page_has_selector 'form#new_toolkit_page'

      fill_in 'toolkit_page_name', with: page_name
      fill_in 'toolkit_page_title', with: page_title
      click_button 'submit'

      expect(ToolkitPage.count).to eql(original_page_count + 1)

      last_page = ToolkitPage.last
      visit toolkit_edit_path(last_page.name)
      page_has_selector 'h1', text: "Editing: #{last_page.name}"
    end
  end
end
