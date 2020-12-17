describe 'Users Admin Pages', :type => :feature do
  let!(:admin_user) { create_admin_user }
  let!(:current_user) { admin_user }
  let!(:restricted_user) { create_user(username: 'restricted', is_restricted: true) }
  let!(:not_restricted_user) { create_user(username: 'not_restricted', is_restricted: false) }

  before { login_as(current_user, :scope => :user) }
  after { logout(:user) }

  describe 'viewing all users' do
    before { visit '/users/admin' }

    it 'displays the index page' do
      expect(page).not_to have_selector 'div.alert'
    end

    it 'has one PERMIT form for the restircted user' do
      expect(page).to have_selector 'button', text: 'Remove restriction', count: 1
    end

    it 'has one RESTRICT form for the not_restircted user' do
      expect(page).to have_selector 'button', text: 'Restrict this user', count: 1
    end

    it 'shows 3 users' do
      expect(page).to have_selector 'table.table tbody tr', count: 3
    end

    it 'will allow restriction to be removed' do
      expect(User.find(restricted_user.id).restricted?).to be true
      page.find("form#restrict_#{restricted_user.id} button").click
      expect(User.find(restricted_user.id).restricted?).to be false
      expect(page).to have_selector 'button', text: 'Restrict this user', count: 2
      expect(page).to have_selector 'div.alert', count: 1
    end

    it 'will allow restriction to be added' do
      expect(User.find(not_restricted_user.id).restricted?).to be false
      page.find("form#restrict_#{not_restricted_user.id} button").click
      expect(User.find(not_restricted_user.id).restricted?).to be true
      expect(page).to have_selector 'button', text: 'Remove restriction', count: 2
      expect(page).to have_selector 'div.alert', count: 1
    end
  end

  describe 'searching for users named "restricted"' do
    before { visit '/users/admin?q=restricted' }

    it 'shows 2 users' do
      expect(page).to have_selector 'table.table tbody tr', count: 2
    end
  end

  describe 'Edit Permissions page' do
    let(:test_user) { create(:user) }
    let(:edit_permissions_url) { "/users/#{test_user.id}/edit_permissions" }

    before { visit edit_permissions_url }

    describe 'as a regular user' do
      let(:current_user) { create_basic_user }

      denies_access
    end

    it 'shows table with abilities' do
      successfully_visits_page edit_permissions_url

      page_has_selector 'table#users-edit-permissions-table tbody tr', count: 8
      page_has_selector 'table#users-edit-permissions-table tbody tr td a', text: 'ADD', count: 7
      page_has_selector 'table#users-edit-permissions-table tbody tr td a', text: 'DELETE', count: 1
    end

    it 'adding the bulk permisison permisison' do
      successfully_visits_page edit_permissions_url

      expect(test_user.abilities.include?(:bulk)).to be false

      find('.add-user-ability-bulk').click

      successfully_visits_page edit_permissions_url
      page_has_selector 'table#users-edit-permissions-table tbody tr td a', text: 'DELETE', count: 2
      expect(page).to have_text 'Permission was successfully added.'
      expect(test_user.reload.abilities.include?(:bulk)).to be true
    end

    it 'removing the edit permisison permisison' do
      successfully_visits_page edit_permissions_url

      expect(test_user.abilities.include?(:edit)).to be true

      find('.delete-user-ability-edit').click

      successfully_visits_page edit_permissions_url
      page_has_selector 'table#users-edit-permissions-table tbody tr td a', text: 'ADD', count: 8
      expect(page).to have_text 'Permission was successfully deleted.'
      expect(test_user.reload.abilities.include?(:edit)).to be false
    end
  end
end
