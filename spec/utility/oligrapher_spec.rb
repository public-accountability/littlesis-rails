require 'rails_helper'

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
end
