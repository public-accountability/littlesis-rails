# frozen_string_literal: true

describe 'home/dashboard', type: :feature do
  let(:current_user) { create_basic_user(password: 'password') }

  context 'with a logged-out user' do
    let(:entity) { create(:entity_org) }

    after { logout(:user) }

    it 'user clicks login and is taken to the dashboard' do
      visit org_path(entity)

      within 'nav' do
        click_on 'Login'
      end

      expect(page).to have_css('h2', text: 'Log in')

      within '#new_user' do
        fill_in 'email', with: current_user.email
        fill_in 'password', with: 'password'
        click_on 'Log in'
      end

      expect(page).to show_success('Signed in successfully.')

      expect(page).to have_css('h1', text: 'LittleSis Dashboard')
    end
  end

  context 'when logged in as an admin' do
    let(:current_user) { create_admin_user }

    before do
      login_as(current_user, :scope => :user)
      visit '/home/dashboard'
    end

    after { logout(:user) }

    specify 'has admin link in dropdown' do
      expect(page).to have_selector 'ul.nav li a', text: 'Admin'
    end
  end

  describe 'Using the navigation bar on top of the basic as a regular user' do
    before do
      login_as(current_user, :scope => :user)
      visit '/home/dashboard'
    end

    after { logout(:user) }

    it 'has nav dropdown' do
      successfully_visits_page home_dashboard_path

      [current_user.username, 'Tags', 'Donate', 'Help'].each do |text|
        expect(page).to have_selector 'ul.nav li a', text: text
      end
      # verifying that networks have been removed
      expect(page).not_to have_selector 'ul.nav li a', text: 'United States'
      # verifying admin page is not accessible
      expect(page).not_to have_selector 'ul.nav li a', text: 'Admin'
    end
  end

  describe 'explore' do
    before do
      login_as(current_user, :scope => :user)
      visit home_dashboard_path
    end

    after { logout(:user) }

    it 'contains links to maps, lists, tags and edits' do
      %w[Maps Lists Tags Edits].each do |option|
        page_has_selector '#dashboard-explore > a', text: option
      end
    end
  end

  describe 'viewing map thumbnails' do
    before { login_as(current_user, :scope => :user) }

    after { logout(:user) }

    context 'when User has one map, without a screenshot' do
      before do
        create(:network_map,
               user_id: current_user.id,
               screenshot: nil,
               is_private: false)
        visit '/home/dashboard'
      end

      it  'page has default map image' do
        successfully_visits_page home_dashboard_path
        page_has_selector 'div.dashboard-map-thumbnail', count: 1
        expect(page.find('.dashboard-map-thumbnail img')['src']).to include 'netmap-org'
        expect(page).not_to have_selector '#dashboard-maps-row div.pagination'
      end
    end

    context 'when user has more maps than the limit shown per page' do
      def page_has_n_maps(n)
        page_has_selector '#dashboard-maps-row div.pagination', count: 1
        page_has_selector 'div.dashboard-map', count: n
      end

      before do
        # see https://github.com/rspec/rspec-mocks/issues/1079#issuecomment-215620243
        # for details on why string interpolation is needed
        stub_const("#{UserDashboardPresenter}::DASHBOARD_MAPS_PER_PAGE", 2)
        create_list(:network_map, 3, user_id: current_user.id)
      end

      specify 'visiting page 1' do
        visit '/home/dashboard'
        page_has_n_maps(2)
      end

      specify 'visiting page 2' do
        visit '/home/dashboard?map_page=2'
        page_has_n_maps(1)
      end
    end
  end

  describe 'viewing list of lists' do
    before { login_as(current_user, :scope => :user) }

    after { logout(:user) }

    describe 'user has two lists' do
      let(:lists) do
        [create(:open_list, creator_user_id: current_user.id),
         create(:private_list, creator_user_id: current_user.id)]
      end

      before { lists }

      specify 'user can see the lists' do
        visit home_dashboard_path
        successfully_visits_page home_dashboard_path
        page_has_selector '#dashboard-lists-links > a', count: 2
      end
    end

    describe 'pagnation' do
      before do
        stub_const("#{UserDashboardPresenter}::DASHBOARD_LISTS_PER_PAGE", 2)
        create_list(:list, 3, creator_user_id: current_user.id)
      end

      specify 'viewing page 1' do
        visit '/home/dashboard'
        page_has_selector '#dashboard-lists-links > a', count: 2
      end

      specify 'viewing page 2' do
        visit '/home/dashboard?list_page=2'
        page_has_selector '#dashboard-lists-links > a', count: 1
      end
    end
  end

  describe 'viewing dashboard bulletins' do
    before do
      login_as(current_user, :scope => :user)
      DashboardBulletin.create!(title: 'title A')
      DashboardBulletin
        .create!(title: 'title B')
        .tap { |b| b.update_column(:created_at, 1.day.ago) }
      visit '/home/dashboard'
    end

    after { logout(:user) }

    let(:a_selector) { '#dashboard-bulletins .card:nth-child(1)' }
    let(:b_selector) { '#dashboard-bulletins .card:nth-child(2)' }

    it 'user can see 2 bulletins' do
      successfully_visits_page home_dashboard_path
      page_has_selector 'div.card', count: 2

      expect(find("#{a_selector} .card-header")).to have_text('title A')
      expect(find("#{b_selector} .card-header")).to have_text('title B')
    end
  end
end
