describe Oligrapher do
  let(:entity) { build(:org, :with_org_name) }

  describe "Node.from_entity" do
    specify do
      expect(Oligrapher::Node.from_entity(entity))
        .to eql(id: entity.id.to_s,
                name: entity.name,
                image: nil,
                description: nil,
                url: "http://test.host/org/#{entity.to_param}")
    end
  end

  describe "rel_to_edge" do
    let(:entity1_id) { rand(1000) }
    let(:entity2_id) { rand(1000) }

    context 'with a current donation relationship' do
      let(:rel) do
        build(:donation_relationship, entity1_id: entity1_id, entity2_id: entity2_id)
      end

      specify do
        expect(Oligrapher.rel_to_edge(rel))
          .to eql({
            id: rel.id.to_s,
            node1_id: entity1_id.to_s,
            node2_id: entity2_id.to_s,
            label: 'Donation/Grant',
            arrow: '1->2',
            dash: false,
            url: "http://test.host/relationships/#{rel.id}"
                  })
      end
    end

    context 'with a current social relationship' do
      let(:rel) do
        build(:social_relationship, entity1_id: entity1_id, entity2_id: entity2_id)
      end

      specify do
        expect(Oligrapher.rel_to_edge(rel))
          .to eql({
            id: rel.id.to_s,
            node1_id: entity1_id.to_s,
            node2_id: entity2_id.to_s,
            label: 'Social',
            arrow: nil,
            dash: false,
            url: "http://test.host/relationships/#{rel.id}"
                  })
      end
    end
  end
end
