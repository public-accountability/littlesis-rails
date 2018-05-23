require 'rails_helper'

feature '/entities/new', type: :feature do
  let(:user) { create_basic_user }
  before(:each) { login_as(user, scope: :user) }
  after(:each) { logout(:user) }

  context 'linked to add entity with page a name' do
    let(:url) { '/entities/new?name=exxon' }
    before { visit url }

    scenario 'adding new entity' do
      successfully_visits_page url
      expect(find('#entity_name').value).to eql 'exxon'
    end
  end

end
