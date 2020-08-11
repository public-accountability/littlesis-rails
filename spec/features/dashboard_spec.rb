# frozen_string_literal: true

describe 'home/dashboard', type: :feature do
  let(:current_user) { create_basic_user }

  before { login_as(current_user, :scope => :user) }

  after { logout(:user) }

  context 'as an admin' do
    let(:current_user) { create_admin_user }

    before do
      visit '/home/dashboard'
    end

    specify 'has admin link in dropdown' do
      expect(page).to have_selector 'ul.nav li a', text: 'Admin'
    end
  end

  describe 'Using the navigation bar on top of the basic as a regular user' do
    before { visit '/home/dashboard' }

    scenario 'nav dropdown' do
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
    before { visit home_dashboard_path }

    scenario 'contains links to maps, lists, tags and edits' do
      %w[Maps Lists Tags Edits].each do |option|
        page_has_selector '#dashboard-explore > a', text: option
      end
    end
  end

  describe 'viewing map thumbnails' do
    context 'when User has one map, with a nil thumbnail' do
      before do
        create(:network_map,
               user_id: current_user.id,
               thumbnail: nil,
               is_private: false)
        visit '/home/dashboard'
      end

      scenario 'pages has default map image' do
        successfully_visits_page home_dashboard_path
        page_has_selector 'img.dashboard-map-thumbnail', count: 1
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

      scenario 'visiting page 1' do
        visit '/home/dashboard'
        page_has_n_maps(2)
      end

      scenario 'visiting page 2' do
        visit '/home/dashboard?map_page=2'
        page_has_n_maps(1)
      end
    end
  end

  describe 'viewing list of lists' do
    describe 'user has two lists' do
      let(:lists) do
        [create(:open_list, creator_user_id: current_user.id),
         create(:private_list, creator_user_id: current_user.id)]
      end

      before { lists }

      scenario 'user can see the lists' do
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

      scenario 'viewing page 1' do
        visit '/home/dashboard'
        page_has_selector '#dashboard-lists-links > a', count: 2
      end

      scenario 'viewing page 2' do
        visit '/home/dashboard?list_page=2'
        page_has_selector '#dashboard-lists-links > a', count: 1
      end
    end
  end

  describe 'viewing dashboard bulletins' do
    before do
      DashboardBulletin.create!(title: 'title A', markdown: '# contentA')
      DashboardBulletin
        .create!(title: 'title B', markdown: '# contentB')
        .tap { |b| b.update_column(:created_at, 1.day.ago) }
      visit '/home/dashboard'
    end

    let(:a_selector) { '#dashboard-bulletins .card:nth-child(1)' }
    let(:b_selector) { '#dashboard-bulletins .card:nth-child(2)' }

    scenario 'user can see 2 bulletins' do
      successfully_visits_page home_dashboard_path
      page_has_selector 'div.card', count: 2

      expect(find("#{a_selector} .card-header")).to have_text('title A')
      expect(find("#{a_selector} .card-body h1")).to have_text('contentA')
      expect(find("#{b_selector} .card-header")).to have_text('title B')
      expect(find("#{b_selector} .card-body h1")).to have_text('contentB')
    end
  end
end

# rubocop:enable Capybara/FeatureMethods
