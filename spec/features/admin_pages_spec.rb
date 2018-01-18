require 'rails_helper'

describe 'Admin Only Pages', :tag_helper, :type => :feature do
  seed_tags # seeds db w/ 3 tags

  let(:admin) { create_admin_user }
  let(:normal_user) { create_really_basic_user }
  let(:user) { normal_user }

  before(:each) { login_as(user, scope: :user) }
  after(:each) { logout(:user) }

  feature 'Accessing the admin home page' do
    before(:each) { visit '/admin' }

    context 'An admin can view the the home page' do
      let(:user) { admin }

      it 'displays the admin page' do
        expect(page.status_code).to eq 200
        expect(page).to have_current_path('/admin')
        expect(page).to have_content 'Rails Admin'
      end
    end

    context 'A regular user cannot view the home page' do
      let(:user) { normal_user }
      denies_access
    end
  end

  feature 'Tag admin page' do
    before(:each) { visit '/admin/tags' }
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

      expect(Tag.count).to eql(4)
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

    context 'as a regular user' do
      let(:user) { normal_user }
      denies_access
    end
  end

  feature 'Stats page' do
    context 'as an admin' do
      let(:user) { admin }
      let(:editor1) { create_really_basic_user }
      let(:editor2) { create_really_basic_user }
      let!(:versions) do
        [
          create(:entity_version, whodunnit: editor1.id.to_s),
          create(:entity_version, whodunnit: editor1.id.to_s),
          create(:entity_version, whodunnit: editor2.id.to_s)
        ]
      end
      before { visit '/admin/stats' }

      scenario 'admin visits stats page' do
        successfully_visits_page '/admin/stats'
        page_has_selector 'table#active-users-table'
        page_has_selector '#active-users-table tbody tr', count: 2
        expect(page).to have_text "Users active in the last 30 days: 2"
      end
    end

    context 'as a regular user' do
      let(:user) { normal_user }
      before { visit '/admin/stats' }
      denies_access
    end
  end
end
