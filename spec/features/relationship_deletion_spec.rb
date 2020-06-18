describe 'deleting relationships' do
  let(:user1) { create_basic_user }
  let(:user2) { create_basic_user }
  let(:admin) { create_admin_user }
  let(:person) { create(:entity_person) }
  let(:org) { create(:entity_org) }

  describe 'request to removed relationship' do
    before { login_as(admin, scope: :user) }

    after { logout(:user) }

    let(:relationship) do
      create(:donation_relationship, entity: person, related: org, currency: 'USD', amount: 2)
    end

    scenario 'deleting relationship via "remove" button' do
      visit relationship_path(relationship)
      expect(page.status_code).to eq 200
      expect do
        page.driver.submit :delete, relationship_path(relationship), {}
      end.to change(Relationship, :count).by(-1)
      visit relationship_path(relationship)
      expect(page.status_code).to eq 404
    end
  end

  describe 'history on associated entity profile pages' do
    let(:relationship) do
      with_versioning_for(user1) do
        Relationship.create!(entity: person, related: org, category_id: 1)
      end
    end

    before { relationship }

    it 'shows correct user on entity page' do
      visit entity_path(person)
      expect(find('#entity-edited-history').text).to include user1.username
    end

    context 'when logged in as user2' do
      before { login_as(user2, scope: :user) }

      after { logout(:user) }

      it 'shows correct user on entity page after deleting' do
        visit entity_path(person)
        expect(find('#entity-edited-history').text).to include user1.username
        with_versioning_for(user2) do
          relationship.current_user = user2
          relationship.soft_delete
        end
        visit entity_path(person)
        expect(find('#entity-edited-history').text).to include user2.username
        visit entity_path(org)
        expect(find('#entity-edited-history').text).to include user2.username
      end
    end
  end
end
