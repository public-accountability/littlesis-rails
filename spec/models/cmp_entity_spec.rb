describe CmpEntity, type: :model do
  it { is_expected.to have_db_column(:entity_id) }
  it { is_expected.to have_db_column(:cmp_id) }
  it { is_expected.to have_db_column(:entity_type) }
  it { is_expected.to have_db_column(:strata).of_type(:integer) }

  describe 'strata validation' do
    let(:entity) { build(:entity_org) }

    specify { expect(build(:cmp_entity, entity: entity, strata: 1)).to be_valid }
    specify { expect(build(:cmp_entity, entity: entity, strata: 5)).to be_valid }
    specify { expect(build(:cmp_entity, entity: entity, strata: nil)).to be_valid }
    specify { expect(build(:cmp_entity, entity: entity, strata: 11)).not_to be_valid }
  end

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
