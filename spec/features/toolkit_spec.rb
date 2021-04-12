feature 'Editable Toolkit Pages' do
  let(:admin) { create_admin_user }
  let(:index) { create(:toolkit_page, name: 'index', markdown: "# toolkit index\n") }
  let(:toolkit_page) { create(:toolkit_page) }
  let(:page_name) { Faker::Creature::Cat.name }
  let(:page_title) { Faker::Creature::Cat.breed }

  scenario 'visting the toolkit index' do
    index
    visit "/toolkit"
    expect(page.status_code).to eq 200
    page_has_selector 'h1', text: 'toolkit index'
  end

  scenario 'visting a toolkit page' do
    visit "/toolkit/#{toolkit_page.name}"
    expect(page.status_code).to eq 200
    page_has_selector 'h1', text: 'toolkit page'
    page_has_selector 'h2', text: 'content'
    expect(page).to have_title 'a toolkit page - LittleSis'
  end

  context 'as an admin' do
    before { login_as(admin, scope: :user) }
    after { logout(admin) }

    scenario 'Editing the toolkit page' do
      visit "/toolkit/#{toolkit_page.name}/edit"
      expect(page.status_code).to eq 200
      page_has_selector 'h1', text: "Editing: #{toolkit_page.name}"
      page_has_selector "form\#edit_toolkit_page_#{toolkit_page.id}"

      fill_in 'editable-markdown', :with => '## new content'
      click_button 'Update'

      successfully_visits_page "/toolkit/#{toolkit_page.name}"
      page_has_selector 'h2', text: "new content"
      expect(toolkit_page.reload.markdown).to eql '## new content'
    end

    scenario 'Creating a new toolkit page' do
      original_page_count = ToolkitPage.count
      visit "/toolkit/new"
      expect(page.status_code).to eq 200
      page_has_selector 'h1', text: "Create a new toolkit page"
      page_has_selector 'form#new_toolkit_page'

      fill_in 'toolkit_page_name', :with => page_name
      fill_in 'toolkit_page_title', :with => page_title
      click_button 'submit'

      expect(ToolkitPage.count).to eql(original_page_count + 1)

      last_page = ToolkitPage.last
      successfully_visits_page "/toolkit/#{last_page.name}/edit"
      
    end
    
  end
end
