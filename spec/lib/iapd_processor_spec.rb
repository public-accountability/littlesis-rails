describe IapdProcessor do
  describe 'Processing iapd advisors' do
    let(:external_data) { create(:external_data_iapd_advisor) }

    before { external_data }

    it 'creates a new external entity' do
      expect { IapdProcessor.run }.to change(ExternalEntity, :count).by(1)
    end

    it 'duplicate runs use the already existing external entity' do
      IapdProcessor.run
      expect { IapdProcessor.run }.not_to change(ExternalEntity, :count)
    end

    # TODO: Move this test to external_data_spec
    xit 'automatically matches when there is an existing crd number in the database' do
      create(:entity_org)
        .external_links
        .crd
        .create!(link_id: external_data.dataset_id)

      expect { IapdProcessor.process_advisor(external_data) }
        .to change { ee.reload.entity_id }.from(nil).to(entity.id)
    end
  end

  describe 'Processing iapd owners' do
    let(:external_data) { create(:external_data_iapd_owner) }

    before { external_data }

    it 'creates a new external entity' do
      expect { IapdProcessor.run }.to change(ExternalEntity, :count).by(1)
    end

    it 'duplicate runs use the already existing external entity' do
      IapdProcessor.run
      expect { IapdProcessor.run }.not_to change(ExternalEntity, :count)
    end

    xit 'automatically matches when there is an existing crd number in the database' do
      ee = ExternalEntity.iapd_owners.create!(external_data: external_data, primary_ext: 'Person')
      ExternalLink.create!(link_type: 'crd', entity_id: entity.id, link_id: external_data.dataset_id)

      expect { IapdProcessor.process_owner(external_data) }
        .to change { ee.reload.entity_id }.from(nil).to(entity.id)
    end
  end
end
