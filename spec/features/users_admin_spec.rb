require 'rails_helper'

describe "Users Admin Page", :type => :feature do
  before(:all) do
    @admin = create_admin_user
    @restricted_user = create_user_with_sf(username: 'restricted', is_restricted: true)
    @not_restricted_user = create_user_with_sf(username: 'not_restricted', is_restricted: false)
  end

  before(:each) do
    # see: https://github.com/plataformatec/devise/wiki/How-To:-Test-with-Capybara
    login_as(@admin, :scope => :user)
    visit '/users/admin'
  end

  after(:each) { logout(:user) }

  it 'displays the index page' do
    expect(page).to have_selector "table.table"
    expect(page).to have_selector "table.table tbody tr", count: 3
    expect(page).not_to have_selector 'div.alert'
  end

  it 'has one PERMIT form for the restircted user' do
    expect(page).to have_selector 'button', text: 'Remove restriction', count: 1
  end

  it 'has one RESTRICT form for the not_restircted user' do
    expect(page).to have_selector 'button', text: 'Restrict this user', count: 1
  end

  it 'will allow restriction to be removed' do
    expect(User.find(@restricted_user.id).restricted?).to be true
    page.find("form#restrict_#{@restricted_user.id} button").click
    expect(User.find(@restricted_user.id).restricted?).to be false
    expect(page).to have_selector 'button', text: 'Restrict this user', count: 2
    expect(page).to have_selector 'div.alert', count: 1
  end

  it 'will allow restriction to be added' do
    expect(User.find(@not_restricted_user.id).restricted?).to be false
    page.find("form#restrict_#{@not_restricted_user.id} button").click
    expect(User.find(@not_restricted_user.id).restricted?).to be true
    expect(page).to have_selector 'button', text: 'Remove restriction', count: 2
    expect(page).to have_selector 'div.alert', count: 1
  end
end
