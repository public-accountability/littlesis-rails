describe 'External Data/Entities matching tool' do
  before { login_as(create_basic_user, scope: :user) }

  after { logout(:user) }

  feature 'overview page' do
    before { visit external_entities_path }

    it 'has links to individual pages' do
      expect(page.status_code).to eq 200
      page_has_selector '#external-entities-datasets-overview a', count: 3
    end
  end

  feature 'dataset table' do
    before { visit external_entities_path(dataset: 'nycc') }

    it 'shows datatables' do
      expect(page.status_code).to eq 200
      page_has_selector 'table#dataset-table'
      expect(page.html).to match /DataTable\({/
    end
  end

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
