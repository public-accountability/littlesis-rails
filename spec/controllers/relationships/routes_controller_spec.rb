describe Relationships::RoutesController, type: :controller do
  describe 'GET #redirect_to_canonical' do
    subject(:get_request) { get :redirect_to_canonical, params: { id: relationship.id } }

    let(:relationship) { create(:generic_relationship, entity: create(:entity_person), related: create(:entity_person)) }

    it 'redirects to the canonical relationship URL' do
      expect(get_request).to redirect_to relationship_path(relationship)
    end
  end
end
