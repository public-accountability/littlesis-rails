feature 'Editing documents' do
  let(:document) { create(:document) }
  let(:new_attrs) { attributes_for(:document) }
  let(:user) { create_basic_user }

  context 'when not logged in' do
    before { visit edit_document_path(document) }

    redirects_to_login_page
  end

  context 'when logged in' do
    before do
      login_as(user, scope: :user)
      visit edit_document_path(document)
    end

    after { logout(:user) }

    scenario 'shows a page with a form to edit the document' do
      successfully_visits_page edit_document_path(document)
      page_has_selector 'form.edit_document', count: 1
      expect(page).to have_text document.url
      page_has_selector "input\#document_name[value='#{document.name}']"
    end

    scenario 'it can update the display name of a document' do
      successfully_visits_page edit_document_path(document)
      page_has_selector "input\#document_name[value='#{document.name}']"
      fill_in 'document_name', with: new_attrs[:name]
      click_button 'Update'
      successfully_visits_page home_dashboard_path
      visit edit_document_path(document)
      successfully_visits_page edit_document_path(document)
      page_has_selector "input\#document_name[value='#{new_attrs[:name]}']"
    end
  end
end
