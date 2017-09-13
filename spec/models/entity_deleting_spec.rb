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

  describe 'restore!' do
    with_versioning do
      let(:entity) { create(:entity_org) }

      it 'raises error if entity is not deleted' do
        expect { build(:entity_org, is_deleted: false).restore! }.to raise_error(StandardError)
        #expect { create(:entity_org, is_deleted: true).restore! }.not_to raise_error
      end

      it 'reverts is_deleted state' do
        entity
        expect { entity.soft_delete }.to change { entity.is_deleted }.to(true)
        expect { entity.restore! }.to change { entity.is_deleted }.to(false)
      end

      context 'extensions' do
        let(:business_academic) do
          person = create(:entity_person)
          person.add_extension('BusinessPerson')
          person.add_extension('Academic')
          person
        end

        before do
          business_academic.soft_delete
          business_academic.reload
        end

        it 're-creates extension_models' do
          expect(business_academic.business_person).to be nil
          business_academic.restore!
          expect(business_academic.business_person).to be_a BusinessPerson
        end

        it 're-creates extension_records' do
          expect(business_academic.extension_records.length).to be_zero
          business_academic.restore!
          expect(business_academic.reload.extension_records.length).to eql 3

          [1, 29, 31].each do |definition_id|
            expect(business_academic.extension_records.map(&:definition_id)).to include definition_id
          end
          
        end

      end

      it 'restores it\'s images' do
      end

      it 're-creates aliases'

      it "re-creates the entity's taggings"

      context 'entity relationships' do
        it 'un-deletes relationships if the other entity in the relationship has not been deleted'
        it 'restores relationship links'
      end
    end
  end
end
