require "rails_helper"

describe 'Active Record Extensions' do
  describe 'lookup_table_for' do
    let(:entities) { Array.new(2) { create(:entity_org) } }
    let(:entity_ids) { entities.map(&:id) }

    it 'turn a list of entity ids into a Hash from id to <Entity>' do
      expect(Entity.lookup_table_for(entity_ids))
        .to eql(
              entities[0].id => entities[0],
              entities[1].id => entities[1]
            )
    end
  end

end
