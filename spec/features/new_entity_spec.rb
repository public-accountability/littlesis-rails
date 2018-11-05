require 'rails_helper'

describe '/entities/new', type: :feature do
  let(:user) { create_basic_user }

  before { login_as(user, scope: :user) }

  after { logout(:user) }

  describe 'linked to add entity with page a name' do
    let(:url) { '/entities/new?name=exxon' }

    before { visit url }

    it 'adding new entity' do
      successfully_visits_page url
      expect(find('#entity_name').value).to eql 'exxon'
    end
  end
end
