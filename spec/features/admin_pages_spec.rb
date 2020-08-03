describe 'Admin Only Pages', :pagination_helper, :tag_helper, :type => :feature do
  seed_tags # seeds db w/ 3 tags

  let(:admin) { create_admin_user }
  let(:normal_user) { create_really_basic_user }
  let(:user) { normal_user }

  before { login_as(user, scope: :user) }

  after { logout(:user) }

  feature 'Accessing the admin home page' do
    before { visit '/admin' }

    describe 'An admin can view the the home page' do
      let(:user) { admin }

      scenario 'displays the admin page' do
        successfully_visits_page '/admin'
        expect(page).to have_content 'Admin'
        page_has_selector '#admin-links a', count: 8
      end
    end

    describe 'A regular user cannot view the home page' do
      let(:user) { normal_user }

      denies_access
    end
  end

  feature 'Tag admin page' do
    before { visit '/admin/tags' }

    let(:user) { admin }

    scenario 'Displays overview of current tags' do
      expect(page.status_code).to eq 200
      expect(page).to have_current_path '/admin/tags'
      page.assert_selector '#tag-table'
      page.assert_selector '#tag-table tbody tr', count: 3
    end

    scenario 'Admin creates a new tag' do
      fill_in('Name', with: 'cylon')
      fill_in('Description', with: 'spin up those ftl drives')
      page.check('Restricted')
      click_button('Create Tag')

      expect(Tag.count).to eq 4
      expect(Tag.last.attributes.slice('name', 'description', 'restricted'))
        .to eq('name' => 'cylon',
               'description' => 'spin up those ftl drives',
               'restricted' => true)

      expect(page).to have_current_path '/admin/tags'
      expect(page).to have_selector 'div.alert-success', count: 1
      expect(page).not_to have_selector 'div.alert-danger'
    end

    scenario 'Admin tries to create a tag that already exists' do
      tag_count = Tag.count
      fill_in('Name', with: 'nyc')
      fill_in('Description', with: 'all about nyc')
      click_button('Create Tag')
      expect(page).to have_current_path '/admin/tags'
      expect(page).not_to have_selector 'div.alert-success'
      expect(page).to have_selector 'div.alert-danger', count: 1
      expect(Tag.count).to eq tag_count
    end

    context 'with a regular user' do
      let(:user) { normal_user }

      denies_access
    end
  end

  feature 'Stats page' do
    context 'with a normal user' do
      let(:user) { normal_user }

      before { visit '/admin/stats' }

      denies_access
    end

    describe 'with an admin' do
      let(:user) { admin }
      let(:editors) { Array.new(4) { create_really_basic_user } }

      before do
        [
          create(:entity_version, whodunnit: editors[0].id.to_s),
          create(:entity_version, whodunnit: editors[0].id.to_s),
          create(:entity_version, whodunnit: editors[1].id.to_s),
          create(:entity_version, whodunnit: editors[2].id.to_s),
          # editor[3] last edited something two months ago
          create(:entity_version, whodunnit: editors[3].id.to_s).tap { |v| v.update_column(:created_at, 2.months.ago) }
        ]
      end

      scenario 'admin visits stats page' do
        visit '/admin/stats'
        successfully_visits_page '/admin/stats'
        page_has_selector 'table#active-users-table'
        page_has_selector '#active-users-table tbody tr', count: 3
        expect(page).to have_text "Users active in the past week: 3"
        page_has_selector '#time-selectpicker option', count: 5

        expect(find_field('time-selectpicker').find('option[selected]').text)
          .to eql 'Week'
      end

      scenario 'visiting stats from with option 6 months ago' do
        visit '/admin/stats?time=6_months'
        successfully_visits_page '/admin/stats?time=6_months'
        page_has_selector '#active-users-table tbody tr', count: 4
        expect(page).to have_text "Users active in the past 6 months: 4"

        expect(find_field('time-selectpicker').find('option[selected]').text)
          .to eql '6 months'
      end

      describe 'pagination' do
        stub_page_limit UserEdits, limit: 2, const: :ACTIVE_USERS_PER_PAGE
        before { visit '/admin/stats' }

        scenario 'paginating through the table' do
          successfully_visits_page '/admin/stats'
          page_has_selector '#active-users-table tbody tr', count: 2
          expect(page).to have_text "Users active in the past week: 3"
          find('ul li a', text: '2').click
          successfully_visits_page '/admin/stats?page=2'
          page_has_selector '#active-users-table tbody tr', count: 1
        end
      end
    end
  end
end
