describe "ExternalRelationships", type: :request do
  let(:user) { create_basic_user }

  before do
    login_as(user, :scope => :user)
  end

  after { logout(:user) }

  describe 'update' do
    let(:org) { create(:entity_org) }
    let(:er) { create(:external_relationship_schedule_a) }

    it 'matches entity1 with an existing entity' do
      expect do
        patch "/external_relationships/#{er.id}", params: { entity_side: '1', entity_id: org.id }
      end.to change { er.reload.entity1_id }.from(nil).to(org.id)

      expect(response.status).to eq 302
    end

    it 'matches entity2 with an existing entity' do
      expect do
        patch "/external_relationships/#{er.id}", params: { entity_side: '2', entity_id: org.id }
      end.to change { er.reload.entity2_id }.from(nil).to(org.id)
    end

    it 'matches entity1 with a new entity' do

      expect do
        entity = { name: 'xzy corp', primary_ext: 'Org', blurb: '' }
        patch "/external_relationships/#{er.id}", params: { entity_side: '1', entity: entity }
      end.to change(Entity, :count).by(1)

      expect(er.reload.entity1.present?).to be true
    end
  end
end
