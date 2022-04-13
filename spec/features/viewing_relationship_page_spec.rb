describe "Relationship Page", :type => :feature do
  let(:user) { create_basic_user }
  let(:org) { create(:entity_org) }
  let(:person) { create(:entity_person) }
  let(:url) { 'http://example.com' }
  let(:tag) { create(:tag) }

  let(:relationship) do
    rel = Relationship.create!(category_id: 12, entity: org, related: person, last_user_id: user.id)
    rel.add_reference(url: url)
  end

  describe "Anonymous user" do
    describe 'layout' do
      before { visit "/relationships/#{relationship.id}" }

      specify do
        expect(page).to have_selector 'h1.relationship-title-link a', text: relationship.name
        expect(page).to have_selector '#source-links-table tbody tr', count: 1, text: url
        expect(page).not_to have_selector '#tags-container'
      end

      it 'opens the source links in a new tab' do
        page.all('#source-links-table tbody tr a').each do |element|
          expect(element[:target]).to eql '_blank'
        end
      end
    end

    describe 'with tags' do
      before do
        relationship.add_tag(tag.id)
        visit "/relationships/#{relationship.id}"
      end

      specify do
        expect(page).to have_selector '#tags-container'
        expect(page).not_to have_selector 'span.tags-edit-glyph'
      end
    end
  end

  describe 'signed in user' do
    let(:user) { create_editor }

    before do
      relationship.add_tag(tag.id)
      login_as(user, scope: :user)
      visit "/relationships/#{relationship.id}"
    end

    after { logout(:user) }

    specify do
      expect(page).to have_selector '#tags-container'
      expect(page).to have_selector 'span.tags-edit-glyph'
      expect(page).to have_selector '#tags-list li', text: tag.name
    end
  end

  describe 'NYS donation relationship' do
    let(:politician) { create(:entity_person) }
    let(:relationship) do
      create(:nys_donation_relationship,
             entity: person, related: politician, last_user_id: user.id, filings: 2)
    end

    before { visit relationship_path(relationship) }

    specify 'viewing relationship page with filings' do
      successfully_visits_page relationship_path(relationship)
      page_has_selector 'td > strong', text: /^Filings$/, count: 1
    end
  end

  describe 'Federal donation relationship' do
    let(:politician) { create(:entity_person) }
    let(:relationship) do
      create(:federal_donation_relationship,
             entity: person, related: politician, last_user_id: user.id, filings: 2)
    end

    before { visit relationship_path(relationship) }

    specify 'viewing relationship page with FEC filings' do
      successfully_visits_page relationship_path(relationship)
      page_has_selector 'td > strong', text: /^FEC Filings$/, count: 1
    end
  end
end
