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

  context "Anonymous user" do
    subject { page }

    context 'layout' do
      before { visit "/relationships/#{relationship.id}" }
      it { is_expected.to have_selector 'h1.relationship-title-link a', text: relationship.name }
      it { is_expected.to have_selector '#source-links-table tbody tr', count: 1, text: url }
      it { is_expected.not_to have_selector '#tags-container' }
      it 'opens the source links in a new tab' do
        page.all('#source-links-table tbody tr a').each do |element|
          expect(element[:target]).to eql '_blank'
        end
      end
    end

    context 'with tags' do
      let!(:tags) { relationship.add_tag(tag.id) }
      before { visit "/relationships/#{relationship.id}" }
      it { is_expected.to have_selector '#tags-container' }
      it { is_expected.not_to have_selector '#tags-edit-button' }
    end
  end

  context 'signed in user' do
    subject { page }
    let(:user) { create_basic_user }
    let!(:tags) { relationship.add_tag(tag.id) }

    before do
      login_as(user, scope: :user)
      visit "/relationships/#{relationship.id}"
    end
    after { logout(user) }

    it { is_expected.to have_selector '#tags-container' }
    it { is_expected.to have_selector '#tags-edit-button' }
    it { is_expected.to have_selector '#tags-list li', text: tag.name }
  end

  context 'NYS donation relationship' do
    let(:politician) { create(:entity_person) }
    let(:relationship) do
      create(:nys_donation_relationship,
             entity: person, related: politician, last_user_id: user.id, filings: 2)
    end
    before { visit relationship_path(relationship) }

    scenario 'viewing relationship page with filings' do
      successfully_visits_page relationship_path(relationship)
      page_has_selector 'td > strong', text: /^Filings$/, count: 1
    end
  end

  context 'Federal donation relationship' do
    let(:politician) { create(:entity_person) }
    let(:relationship) do
      create(:federal_donation_relationship,
             entity: person, related: politician, last_user_id: user.id, filings: 2)
    end
    before { visit relationship_path(relationship) }

    scenario 'viewing relationship page with FEC filings' do
      successfully_visits_page relationship_path(relationship)
      page_has_selector 'td > strong', text: /^FEC Filings$/, count: 1
    end
  end
end
