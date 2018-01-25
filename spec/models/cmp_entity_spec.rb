require 'rails_helper'

describe CmpEntity, type: :model do
  it { is_expected.to have_db_column(:entity_id) }
  it { is_expected.to have_db_column(:cmp_id) }
  it { is_expected.to have_db_column(:entity_type) }

  describe 'entity type enum' do
    specify do
      expect(build(:cmp_entity, entity_type: 0).entity_type)
        .to eql 'org'
    end
    specify do
      expect(build(:cmp_entity, entity_type: 1).entity_type)
        .to eql 'person'
    end
  end
end
