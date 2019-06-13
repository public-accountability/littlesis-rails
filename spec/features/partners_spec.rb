describe 'Partners' do
  describe 'corporate mapping project landing page' do
    it 'shows page' do
      expect(CmpNetworkMapService).to receive(:random_map_pairs)
                                        .once
                                        .and_return( [ [build(:network_map), build(:network_map)] ] )
      visit '/partners/corporate-mapping-project'
      successfully_visits_page '/partners/corporate-mapping-project'
    end
  end
end
