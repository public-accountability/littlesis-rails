describe 'Partners' do
  describe 'corporate mapping project landing page' do
    before { visit '/partners/corporate-mapping-project' }

    it 'shows page' do
      successfully_visits_page '/partners/corporate-mapping-project'
    end
  end
end
