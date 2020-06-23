describe 'Datasets' do
  before { login_as(create_basic_user, scope: :user) }

  after { logout(:user) }

  feature 'overview page' do
    before { visit datasets_path }

    it 'has links to individual pages' do
      expect(page.status_code).to eq 200
      page_has_selector '#datasets-overview a', count: 3
    end
  end

  feature 'dataset table' do
    before { visit dataset_path(dataset: "nycc") }


    it 'shows datatables' do
      expect(page.status_code).to eq 200
      page_has_selector 'table#dataset-table'
      expect(page.html).to match /DataTable\({/
    end
  end
end
