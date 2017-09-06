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

    it 'displays the tag overview page' do
      expect(page.status_code).to eq 200
      expect(page).to have_current_path '/admin/tags'
    end

    it 'shows a table with all current tags' do
      page.assert_selector '#tag-table'
      page.assert_selector '#tag-table tbody tr', count: 3
    end

    context 'as a regular user' do
      let(:user) { normal_user }
      denies_access
    end
  end
end
