require 'rails_helper'

describe 'Deleting an Entity', type: :model do
  describe 'Deleting an entity with tags' do
    let(:tags) do
      { oil: create(:oil_tag), nyc: create(:nyc_tag) }
    end
    let(:entity) do
      entity = create(:entity_org)
      entity.tag('oil')
      entity.tag('nyc')
      entity
    end

    with_versioning do
      before { tags }

      it 'saves tags on paper trail version' do
        entity.soft_delete
        version = Entity.unscoped.find(entity.id).versions.last
        expect(YAML.load(version.association_data)['tags']).to eql %w(oil nyc)
      end

      it 'deletes the taggings' do
        entity
        expect { entity.soft_delete }.to change { Tagging.count }.by(-2)
      end
    end

  end
end
