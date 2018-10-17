require "rails_helper"

describe 'deleting relationships' do
  let(:person) { create(:entity_person) }
  let(:org) { create(:entity_org) }
  let(:relationship_params) do
    { entity: person, related: org, category_id: 1 }
  end

  let(:user1) { create_basic_user }
  let(:user2) { create_basic_user }

  before do
    with_verisioning_for(user1) do
      @relationship = Relationship.create!(relationship_params)
    end
  end

  it 'shows correct user on entity page' do
    visit entity_path(person)
    expect(find('#entity-edited-history').text).to include user1.username
  end

  context 'when logged in as user2' do
    before { login_as(user2, :scope => :user) }

    after { logout(:user) }

    it 'shows correct user on entity page after deleting' do
      visit entity_path(person)
      expect(find('#entity-edited-history').text).to include user1.username
      with_verisioning_for(user2) do
        @relationship.current_user = user2
        @relationship.soft_delete
      end
      visit entity_path(person)
      expect(find('#entity-edited-history').text).to include user2.username
      visit entity_path(org)
      expect(find('#entity-edited-history').text).to include user2.username
    end
  end
end
