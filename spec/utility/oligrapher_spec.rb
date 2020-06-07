# rubocop:disable RSpec/ExampleLength

describe Oligrapher do
  let(:entity) { build(:org, :with_org_name) }

  describe "annotations_data" do
    let(:network_map1) { create(:network_map_version3, user_id: 1) }
    let(:network_map2) { create(:network_map_version3, user_id: 1, annotations_data: [
      { id: "1", header: "header", text: "text", nodeIds:[1, 2], edgeIds: [], captionIds: [] }
    ].to_json) }

    it "converts annotations_data" do
      expect(Oligrapher.annotations_data(network_map1)).to eql([])
      expect(Oligrapher.annotations_data(network_map2)[0]['id']).to eql("1")
      expect(Oligrapher.annotations_data(network_map2)[0]['title']).to eql("header")
      expect(Oligrapher.annotations_data(network_map2)[0]['nodeIds']).to eql([1, 2])
    end
  end

  describe "Node.from_entity" do
    specify do
      expect(Oligrapher::Node.from_entity(entity))
        .to eql(id: entity.id.to_s,
                name: entity.name,
                image: nil,
                description: nil,
                url: "http://localhost:8080/org/#{entity.to_param}")
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
            url: "http://localhost:8080/relationships/#{rel.id}"
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
            url: "http://localhost:8080/relationships/#{rel.id}"
          })
      end
    end
  end

  describe 'legacy functions' do
    describe 'legacy_entity_to_node' do
      specify do
        expect(Oligrapher.legacy_entity_to_node(entity))
          .to eql(id: entity.id,
                  display: {
                    name: entity.name,
                    image: nil,
                    url: "http://localhost:8080/org/#{entity.to_param}"
                  })
      end
    end

    describe 'legacy_rel_to_edge' do
      let(:entity1_id) { rand(1000) }
      let(:entity2_id) { rand(1000) }

      context 'with a donation relationship' do
        let(:rel) do
          build(:donation_relationship, entity1_id: entity1_id, entity2_id: entity2_id)
        end

        specify do
          expect(Oligrapher.legacy_rel_to_edge(rel))
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

      context 'with a social relationship' do
        let(:rel) do
          build(:social_relationship, entity1_id: entity1_id, entity2_id: entity2_id, is_current: true)
        end

        specify do
          expect(Oligrapher.legacy_rel_to_edge(rel))
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
end

# rubocop:enable RSpec/ExampleLength
