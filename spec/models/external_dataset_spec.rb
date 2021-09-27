describe ExternalDataset, type: :model do
  it 'has shortcut to fetch individual dataset class' do
    expect(ExternalDataset.nycc).to eql ExternalDataset::NYCC
  end

  describe ExternalDataset::FECCommittee do
    let(:fec_committee) { create(:external_dataset_fec_committee) }

    it 'can find littlesis entity through external links' do
      entity = create(:entity_org, name: fec_committee.cmte_nm.titleize).tap do |e|
        e.external_links.create!(link_type: :fec_committee, link_id: fec_committee.cmte_id)
      end

      expect(fec_committee.entity).to eq entity
    end

    it 'can create new littlesis entities' do
      expect(fec_committee.entity).to be nil
      expect { fec_committee.create_littlesis_entity }.to change(Entity, :count).by(1)
      expect(fec_committee.entity).to be_a Entity
    end
  end
end
