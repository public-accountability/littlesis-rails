feature 'Featured list admin', type: :feature, js: true do
  let(:admin) { create_admin_user }
  let(:user) { create_basic_user }
  let!(:nonfeatured_lists) { create_list(:list, 3, is_featured: false) }
  let!(:featured_lists) { create_list(:list, 2, is_featured: true) }

  context 'when logged in as an normal user' do
    before do
      login_as user, scope: :user
      visit "/"

      find("#navmenu-dropdown-Explore").click

      within '.dropdown-menu.show' do
        click_on 'Lists'
      end
    end

    it 'shows featured lists by default' do
      expect(page).to have_css('h1', text: 'Featured Lists')

      featured_lists.each do |list|
        expect(page).to have_css("tr#list_#{list.id}", count: 1)
      end

      nonfeatured_lists.each do |list|
        expect(page).not_to have_css("tr#list_#{list.id}")
      end
    end

    it "doesn't offer featured and deletion options" do
      within '#lists' do
        expect(page).not_to have_css('.star-button')
        expect(page).not_to have_css('.delete-button')
      end
    end
  end

  context 'when logged in as an admin' do
    before do
      login_as admin, scope: :user
      visit "/"

      find("#navmenu-dropdown-Explore").click

      within '.dropdown-menu.show' do
        click_on 'Lists'
      end
    end

    after do
      logout(:user)
    end

    it 'shows featured lists by default' do
      expect(page).to have_css('h1', text: 'Featured Lists')

      featured_lists.each do |list|
        expect(page).to have_css("tr#list_#{list.id}", count: 1)
      end

      nonfeatured_lists.each do |list|
        expect(page).not_to have_css("tr#list_#{list.id}")
      end
    end

    scenario 'admin un-features a featured list' do
      within "tr#list_#{featured_lists.last.id}" do
        find('.star-button').click
      end

      expect(page).to show_success('List was successfully updated.')
      expect(page).not_to have_css("tr#list_#{featured_lists.last.id}")
    end

    scenario 'admin features an unfeatured list' do
      within '#list-index-header' do
        click_on 'All'
      end

      within "tr#list_#{nonfeatured_lists.last.id}" do
        find('.star-button').click
      end

      expect(page).to show_success('List was successfully updated.')

      within '#list-index-header' do
        click_on 'Featured'
      end

      expect(page).to have_css('h1', text: 'Featured Lists')
      expect(page).to have_css("tr#list_#{nonfeatured_lists.last.id}")
    end

    xscenario 'admin deletes a featured list' do
      within "tr#list_#{featured_lists.last.id}" do
        accept_confirm do
          find('.delete-button').click
        end
      end

      expect(page).to show_success('List was successfully destroyed. ')
      expect(page).not_to have_css("tr#list_#{featured_lists.last.id}")
    end
  end
end
