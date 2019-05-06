describe 'NYS' do
  feature 'Finding candidates and committees' do
    let(:importer) { create_importer }
    let(:person) { create(:entity_person) }
    let(:org) { create(:entity_org) }

    before { login_as importer, scope: :user }
    after { logout :user }

    scenario 'viewing results for an Person' do
      expect(NyFiler).to receive(:search_filers).and_return([])
      visit "/nys/candidates/new?entity=#{person.id}"
      expect(page.status_code).to eq 200
      page_has_link '/nys/candidates'
    end

    scenario 'viewing results for an PAC' do
      expect(NyFiler).to receive(:search_pacs).and_return([])
      visit "/nys/candidates/new?entity=#{org.id}"
      expect(page.status_code).to eq 200
      page_has_link '/nys/pacs'
    end
  end
end
