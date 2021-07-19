describe Lists::ListEntitiesController, type: :controller do
  describe '#destroy' do
    login_admin
    let(:list) { create(:list) }
    let(:person) { create(:entity_person) }
    let!(:list_entity) { ListEntity.create!(list_id: list.id, entity_id: person.id) }

    it 'removes the list entity' do
      expect {
        delete :destroy, params: {list_id: list.id, id: list_entity.id}
      }.to change { ListEntity.count }.by(-1)
    end

    it 'redirects to the members page' do
      delete :destroy, params: {list_id: list.id, id: list_entity.id}
      expect(response).to have_http_status(302)
    end
  end
end
