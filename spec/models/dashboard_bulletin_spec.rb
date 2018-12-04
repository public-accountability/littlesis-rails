require 'rails_helper'

describe DashboardBulletin, type: :model do
  it { is_expected.to have_db_column(:markdown) }
  it { is_expected.to have_db_column(:title) }
  it { is_expected.to have_db_column(:color).of_type(:string) }
  it { is_expected.to have_db_index(:created_at) }
end
