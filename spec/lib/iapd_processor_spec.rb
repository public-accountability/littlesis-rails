describe IapdProcessor do
  describe 'process_advisor' do
    let(:external_data) { create(:external_data_iapd_advisor) }
    let(:entity) { create(:entity_org) }

    it 'creates a new external entity' do
      expect { IapdProcessor.process_advisor(external_data) }
        .to change(ExternalEntity, :count).by(1)
    end

    it 'finds the existing external entity' do
      ExternalEntity.iapd_advisors.create!(external_data: external_data)
      expect { IapdProcessor.process_advisor(external_data) }.not_to change(ExternalEntity, :count)
    end

    it 'automatically matches when there is an existing crd number in the database' do
      ee = ExternalEntity.iapd_advisors.create!(external_data: external_data)
      ExternalLink.create!(link_type: 'crd', entity_id: entity.id, link_id: external_data.dataset_id)
      expect { IapdProcessor.process_advisor(external_data) }
        .to change { ee.reload.entity_id }.from(nil).to(entity.id)
    end
  end

  describe 'process_owner' do
  end
end
