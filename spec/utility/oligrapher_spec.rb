describe Oligrapher do
  describe 'entity_to_node' do
    let(:entity) { build(:org, :with_org_name) }

    specify do
      expect(Oligrapher.entity_to_node(entity))
        .to eql(id: entity.id,
                display: {
                  name: entity.name,
                  image: nil,
                  url: "http://localhost:8080/org/#{entity.to_param}"
                })
    end
  end

  describe 'rel_to_edge' do
    let(:entity1_id) { rand(1000) }
    let(:entity2_id) { rand(1000) }

    context 'donation relationship' do
      let(:rel) do
        build(:donation_relationship, entity1_id: entity1_id, entity2_id: entity2_id)
      end

      specify do
        expect(Oligrapher.rel_to_edge(rel))
          .to eql(id: rel.id,
                  node1_id: entity1_id,
                  node2_id: entity2_id,
                  display: {
                    label: 'Donation/Grant',
                    arrow: '1->2',
                    dash: true,
                    url: "http://localhost:8080/relationships/#{rel.id}"
                  })
      end
    end

    context 'social relationship' do
      let(:rel) do
        build(:social_relationship, entity1_id: entity1_id, entity2_id: entity2_id, is_current: true)
      end

      specify do
        expect(Oligrapher.rel_to_edge(rel))
          .to eql(id: rel.id,
                  node1_id: entity1_id,
                  node2_id: entity2_id,
                  display: {
                    label: 'Social',
                    arrow: nil,
                    dash: false,
                    url: "http://localhost:8080/relationships/#{rel.id}"
                  })
      end
    end
  end
end
