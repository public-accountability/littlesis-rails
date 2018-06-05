require 'rails_helper'

describe ExternalLink, type: :model do
  it { is_expected.to have_db_column(:link_type) }
  it { is_expected.to have_db_column(:entity_id) }
  it { is_expected.to have_db_column(:link_id) }
  it { is_expected.to belong_to(:entity) }

  it 'does not allow multiple links of the same type'
end
