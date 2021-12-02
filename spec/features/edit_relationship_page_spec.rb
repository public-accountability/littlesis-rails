describe 'Edit Relationship Page', type: :feature do
  let(:user) { create_basic_user }
  let(:child_org) { create(:entity_org, name: 'child org') }
  let(:parent_org) { create(:entity_org, name: 'parent org') }
  let(:hierarchy_relationship) do
    create(:hierarchy_relationship, entity: child_org, related: parent_org, last_user_id: user.id)
  end

  context 'user is not logged in' do
    before { visit edit_relationship_path(hierarchy_relationship) }
    redirects_to_login_page
  end

  context 'user is logged in' do
    before { login_as(user, scope: :user) }
    after { logout(user) }

    context 'Editing a hiearchical relationship' do
      before { visit edit_relationship_path(hierarchy_relationship) }

      it 'displays relationship title with link' do
        page_has_selector 'h1.relationship-title-link a', count: 1, text: hierarchy_relationship.name
        expect(page.all('h1.relationship-title-link a').first['href'])
          .to eql relationship_path(hierarchy_relationship)
      end

      it 'Shows parent above child' do
        selector = '#relationship-edit-description-fields-display p.description-fields-title'
        page_has_selector selector, count: 2
        expect(page.all(selector).map(&:text)).to eql ['Parent:', 'Child:']
      end
    end # end 'hiearchical relationship

    context 'editing a membership relationship' do
      let(:membership_relationship) do
        create(:membership_relationship, entity: create(:entity_org), related: create(:entity_org), last_user_id: user.id)
      end

      before { visit edit_relationship_path(membership_relationship) }

      it "shows links to entities in correct order: 'member', 'organization'" do
        selector = '#relationship-edit-description-fields-display p.description-fields-title'
        page_has_selector selector, count: 2
        expect(page.all(selector).map(&:text)).to eql ['Member:', 'Organization:']
      end

      it 'has reverse relationship link' do
        page_has_selector '#relationship-reverse-link', count: 1
      end
    end
  end # end 'user is logged in'
end
