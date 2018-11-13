require 'rails_helper'

describe UserProfile, type: :model do
  it { is_expected.to have_db_column(:user_id).of_type(:integer) }
  it { is_expected.to have_db_column(:name_last).of_type(:string) }
  it { is_expected.to have_db_column(:name_first).of_type(:string) }
  it { is_expected.to have_db_column(:reason).of_type(:text) }
  it { is_expected.to belong_to(:user) }
end
