require 'rails_helper'

describe "Users Admin Page", :type => :feature do
  before(:all) { login_as(create_admin_user, :scope => :user) }
  after(:all) { logout(:user) }

  it 'displays the index page' do
    visit '/users/admin'
    expect(page).to have_selector("table.table")
  end

  # context 'user is restricted' do
  #     before do
  #       @user = build(:user, is_restricted: true)
  #     end

  #     it 'removes restriction from user' do
  #       expect { post :restrict, action: 'PERMIT', id: 123 }.not_to change { @user.is_restricted }
  #     end
  #   end
end
