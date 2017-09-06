require 'rails_helper'

describe 'Admin Only Pages', :type => :feature do
  let(:admin) { create_admin_user }
  let(:normal_user) { create_really_basic_user }
  let(:user) { normal_user }

  feature 'Accessing the admin home page' do
    before(:each) do
      login_as(user, scope: :user)
      visit '/admin'
    end

    after(:each) { logout(:user) }

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

      it 'denies access' do
        expect(page.status_code).to eq 403
        expect(page).to have_content 'Bad Credentials'
      end
    end
  end
end
