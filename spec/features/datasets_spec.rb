describe 'Datasets' do
  before { login_as(create_collaborator, scope: :user) }

  after { logout(:user) }

  describe 'overview page' do
    before { visit datasets_path }

    it 'has links to individual pages' do
      expect(page.status_code).to eq 200
      page_has_selector '#datasets-overview'
    end
  end

  describe 'dataset table' do
    before { visit dataset_path(dataset: "nycc") }

    it 'shows datatables' do
      expect(page.status_code).to eq 200
      page_has_selector 'table.datagrid'
    end
  end
end
