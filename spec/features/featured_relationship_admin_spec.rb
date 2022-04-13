describe 'Featured relationship admin', type: :feature do
  let(:admin) { create_admin_user }
  let(:user) { create_basic_user }
  let(:org) { create(:entity_org) }
  let!(:relationships) { create_list(:generic_relationship, 5, entity: org, related: create(:person)) }

  context 'when logged in as an normal user' do
    before do
      login_as user, scope: :user
    end

    context 'when on the entity profile page' do
      before do
        visit org_path(org)
      end

      it 'does not offer the featured relationship button' do
        expect(page).not_to have_css('.star-button')
      end
    end

    context 'when on the relationship page' do
      before do
        visit edit_relationship_path(relationships.last)
      end

      it 'does not offer the featured relationship button' do
        expect(page).not_to have_css('.star-button')
      end
    end
  end

  context 'when logged in as an editor' do
    before do
      login_as create_editor, scope: :user
      visit edit_relationship_path(relationships.last)
    end

    it 'can feature and unfeature the relationship' do
      within '#relationship-action-buttons' do
        expect(page).to have_button 'feature'
      end

      expect(relationships.last.is_featured).to be false

      within '#relationship-action-buttons' do
        click_button 'feature'
      end

      # expect(page).to show_success('Relationship updated')

      expect(relationships.last.reload.is_featured).to be true

      within '#relationship-action-buttons' do
        click_button 'unfeature'
      end

      # expect(page).to show_success('Relationship updated')

      expect(relationships.last.reload.is_featured).to be false
    end

  end

  context 'when logged in as an admin' do
    before do
      admin.settings.update(show_stars: true)
      admin.save!
      login_as admin, scope: :user
    end

    context 'when on the entity profile page' do
      before do
        visit org_path(org)
      end

      it 'can feature and unfeature a relationship' do
        expect(page).to have_css('.star-button')
        expect(relationships.last.is_featured).to be false

        all('.star-button').last.click

        # expect(page).to show_success('Relationship updated')

        expect(relationships.last.reload.is_featured).to be true

        all('.star-button').last.click


        # expect(page).to show_success('Relationship updated')

        expect(relationships.last.reload.is_featured).to be false
      end
    end

    context 'when on the relationship page' do
      before do
        visit edit_relationship_path(relationships.last)
      end

      it 'can feature and unfeature the relationship' do
        within '#relationship-action-buttons' do
          expect(page).to have_button 'feature'
        end

        expect(relationships.last.is_featured).to be false

        within '#relationship-action-buttons' do
          click_button 'feature'
        end

        # expect(page).to show_success('Relationship updated')

        expect(relationships.last.reload.is_featured).to be true

        within '#relationship-action-buttons' do
          click_button 'unfeature'
        end

        # expect(page).to show_success('Relationship updated')

        expect(relationships.last.reload.is_featured).to be false
      end
    end
  end
end
