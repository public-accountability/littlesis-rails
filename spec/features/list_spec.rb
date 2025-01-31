describe 'lists', type: :feature do
  describe 'list page', type: :feature do
    let(:document_attributes) { attributes_for(:document) }

    let!(:list) do
      create(:list, created_at: Time.current).tap do |l|
        ListEntity.create!(list_id: l.id, entity_id: create(:entity_person).id)
        l.add_reference(document_attributes)
      end
    end

    let!(:earlier_list) do
      create(:list, created_at: 1.year.ago).tap do |l|
        ListEntity.create!(list_id: l.id, entity_id: create(:entity_person).id)
        l.add_reference(document_attributes)
      end
    end

    scenario 'visiting the list page' do
      visit list_path(list)
      successfully_visits_page(list_path(List.first) + '/members')
      expect(page.find('#list-header')).to have_text list.name
      expect(page).not_to have_selector '#list-tags-container'
    end

    scenario 'navigating to the sources tab' do
      visit list_path(list)
      click_on 'Sources'
      successfully_visits_page(list_path(List.first) + '/references')
      page_has_selector '#list-sources'
      expect(page).to have_link document_attributes[:name], href: document_attributes[:url]
    end

    feature 'list page with tags' do
      let(:tag) { create(:tag) }

      before do
        list.add_tag(tag.id)
      end

      scenario 'tags are visable on the page' do
        visit list_path(list)
        expect(page).to have_selector '#list-tags-container'
        expect(page).to have_selector '#tags-list li', text: tag.name
      end
    end

    feature 'viewing modifications to a list' do
      let(:user) { create_basic_user }

      after { logout(:user) }

      with_versioning do
        before do
          login_as(user, scope: :user)
          PaperTrail.request(whodunnit: user.id.to_s) do
            @list = create(:list, creator_user_id: user.id)
          end
        end

        scenario 'list has been created' do
          visit "#{list_path(List.last)}/modifications"

          page_has_selectors '#list-header', '#list-tab-menu'
          page_has_selector '.tab', text: 'Sources'

          page_has_selector '#record-history-container'
          page_has_selector '#record-history-container table tr', count: 1
          expect(page).to have_text "#{user.username} created the list"
        end

        context 'when adding an entity to the list' do
          before do
            login_as(user, scope: :user)
            PaperTrail.request(whodunnit: user.id.to_s) do
              ListEntity.create!(list: @list, entity: create(:entity_org))
            end
          end

          it 'shows both edits' do
            visit "#{list_path(List.last)}/modifications"
            page_has_selector '#record-history-container table tr', count: 3
          end
        end
      end
    end
  end

  describe "sorting a list by the donations column" do
    let(:user) { create_admin_user }
    let(:entity) { create(:entity_person) }
    let(:entity2) { create(:entity_org) }
    let(:donation) { create(:donation_relationship, entity: entity, entity2_id: entity2.id, amount: 323_00) }
    let!(:list) do
      create(:list, sort_by: nil).tap do |l|
        ListEntity.create!(list_id: l.id, entity_id: entity.id)
      end
    end

    before do
      login_as(user, scope: :user)
      visit edit_list_path(list)
    end

    scenario "user shows the list's donations column then hides it again" do
      within '.edit_list' do
        select 'Total usd donations', from: 'Sort by'
        click_on 'Save'
      end

      expect(page).to have_css('.alert-success', text: 'List was successfully updated.')
      expect(list.reload.sort_by).to eq('total_usd_donations')

      within '.list-actions' do
        click_on 'edit'
      end

      expect(page).to have_css('h3', text: 'Edit:')
      within '.edit_list' do
        select '', from: 'Sort by'
        click_on 'Save'
      end

      expect(list.reload.sort_by.blank?).to be true
    end
  end
end
