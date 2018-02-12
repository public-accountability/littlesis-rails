require 'rails_helper'

feature 'EntityHistoryPage' do
  let(:users) { Array.new(3) { create_really_basic_user } }
  let(:entity) { create(:entity_person) }
  let(:tag) { create(:tag) }

  before do
    with_versioning do
      # craete entity with 3 history items:
      PaperTrail.whodunnit(users[0].id.to_s) { entity }
      PaperTrail.whodunnit(users[1].id.to_s) { entity.add_extension('Lawyer') }
      PaperTrail.whodunnit(users[2].id.to_s) { entity.add_tag(tag.id) }
    end
    login_as(users[0], scope: :user)
  end

  after { logout(:user) }

  scenario 'viewing the history page' do
    visit edits_entity_path(entity)
    successfully_visits_page edits_entity_path(entity)
  end

end
