feature 'DashboardBulletins', type: :feature do
  before { login_as(user, :scope => :user) }
  after { logout(:user) }

  context 'as a regular user' do
    let(:user) { create_really_basic_user }
    before { visit '/dashboard_bulletins/new' }
    denies_access
  end

  context 'as an admin user' do
    let(:user) { create_admin_user }
    let(:title) { Faker::Book.title }

    feature 'viewing all bulletins' do
      before do
        DashboardBulletin.create!(title: title )
        visit '/dashboard_bulletins'
      end

      scenario 'has table of bulletins' do
        successfully_visits_page '/dashboard_bulletins'

        page_has_selector '#dashboard-bulletins-table'
        page_has_selector '#dashboard-bulletins-table tbody tr', count: 1
        expect(find('#dashboard-bulletins-table').text).to include title
      end
    end

    feature 'creating a bulletin' do
      before { visit '/dashboard_bulletins/new' }

      successfully_visits_page('/dashboard_bulletins/new')

      scenario 'admin adds a new bulletins' do
        fill_in 'dashboard_bulletin_title', :with => title
        click_button 'Create'

        expect(DashboardBulletin.count).not_to eql 0

        successfully_visits_page('/home/dashboard')
      end
    end

    feature 'modifying existing bulletins' do
      let(:bulletin) { DashboardBulletin.create!(title: title) }

      before do
        allow(Rails.cache).to receive(:delete_matched)
        bulletin
      end

      scenario 'updating the bulletin\'s content' do
        visit edit_dashboard_bulletin_path(bulletin)
        successfully_visits_page edit_dashboard_bulletin_path(bulletin)
        click_button 'Update'

        successfully_visits_page('/home/dashboard')
      end

      scenario 'removing a bulletin' do
        bulletin_count = DashboardBulletin.count
        visit '/dashboard_bulletins'

        find('#dashboard-bulletins-table tr:first-of-type > td:nth-child(2) > form > button').click
        expect(DashboardBulletin.count).to eql (bulletin_count - 1)

        successfully_visits_page('/home/dashboard')
      end
    end

  end
end
