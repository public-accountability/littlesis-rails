describe 'External Data/Entities matching tool' do
  before { login_as(create_basic_user, scope: :user) }
  after { logout(:user) }

  feature 'external data view' do
    let(:external_data) { create(:external_data_iapd_advisor) }
    let(:external_entity) do
      external_data.create_external_entity!(dataset: 'iapd_advisors')
    end

    let(:request) do
      proc { visit external_entity_path(external_entity) }
    end

    specify 'page layout' do
      allow(EntityMatcher).to receive(:find_matches_for_org).and_return([])
      request.call
      expect(page.status_code).to eq 200
      expect(page.html).to include "Boenning"
      expect(page.html).to include "CRD Number"
      page_has_selectors '#external-entity-matcher', 'div.header'
      page_has_selector 'div.tab-pane', count: 3
    end
  end

  feature 'matching with an existing entity'
  feature 'matching and creating a new entity'
end
