require 'rails_helper'

describe CmpRelationship, type: :model do
  it { is_expected.to have_db_column(:relationship_id) }
  it { is_expected.to have_db_column(:cmp_affiliation_id) }
  it { is_expected.to have_db_column(:cmp_org_id) }
  it { is_expected.to have_db_column(:cmp_person_id) }
  it { is_expected.to belong_to(:relationship) }
end
