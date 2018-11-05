require 'rails_helper'

describe '/entities/new', type: :feature do
  let(:user) { create_basic_user }

  before { login_as(user, scope: :user) }

  after { logout(:user) }

  describe 'linked to add entity with page a name' do
    let(:url) { '/entities/new?name=exxon' }

    before { visit url }

    it 'has name field already filled out' do
      successfully_visits_page url
      expect(find('#entity_name').value).to eql 'exxon'
    end
  end

  describe 'creating a new entity' do
    before { visit '/entities/new' }

    let(:name) { Faker::Name.name }
    let(:blurb) { Faker::Shakespeare.hamlet_quote }

    it 'can create a new person' do
      successfully_visits_page '/entities/new'

      fill_in 'entity_name', with: name
      fill_in 'entity_blurb', with: blurb
      choose 'Person'
      click_button 'Add'

      expect(page.status_code).to eq 200
      expect(Entity.last.name).to eql name
      expect(page.current_path).to include '/person/'
      expect(page.current_path).to include '/edit'
    end
  end
end
