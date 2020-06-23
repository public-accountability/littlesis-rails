describe ExternalEntitiesHelper, type: :helper do
  describe 'external_entities_tab' do
    it 'renders div with active class' do
      expect(helper.external_entities_tab('test', active: true, &proc {})).to include "active"
      expect(helper.external_entities_tab('test', active: false, &proc {})).not_to include "active"
      expect(helper.external_entities_tab('test', &proc {})).not_to include "active"
    end
  end
end
