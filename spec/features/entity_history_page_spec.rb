feature 'EntityHistoryPage' do
  let(:users) { Array.new(3) { create_editor } }
  let(:entity) { create(:entity_person) }
  let(:tag) { create(:tag) }

  feature 'viewing entity page' do
    before do
      allow(Tag).to receive(:lookup).and_return(double(:fetch => tag))

      with_versioning do
        # create an entity with 3 history items:
        PaperTrail.request(whodunnit: users[0].id.to_s) { entity }
        PaperTrail.request(whodunnit: users[1].id.to_s) { entity.add_extension('Lawyer') }
        PaperTrail.request(whodunnit: users[2].id.to_s) { entity.add_tag(tag.id) }
      end
      login_as(users[0], scope: :user)
    end

    after { logout(:user) }

    scenario 'viewing the history page' do
      visit history_entity_path(entity)
      successfully_visits_page history_entity_path(entity)

      expect(page).to have_title "Edits: #{entity.name}"
      page_has_selector "#record-history-container"
      page_has_selector "#record-history-container table tbody tr", count: 3
      expect(page).to have_content "added extension Lawyer"
      expect(page).to have_content "added tag #{tag.name}"
      page_has_selector "h4", text: "Revision history for #{entity.name}"
      expect(page).not_to have_selector '#entity-history-date-caveat'
    end

    context 'entity was created before 2017' do
      before do
        login_as(users[0], scope: :user)
        entity.update_column(:created_at, Time.zone.parse('2016-01-01'))
      end

      after { logout(:user) }

      scenario 'viewing cavet notice' do
        visit history_entity_path(entity)
        successfully_visits_page history_entity_path(entity)
        page_has_selector "h4", text: "Revision history for #{entity.name}"
        page_has_selector '#entity-history-date-caveat'
      end
    end
  end
end
