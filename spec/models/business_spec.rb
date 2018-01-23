require 'rails_helper'

describe Business do
  it { is_expected.to have_db_column(:assets) }
  it { is_expected.to have_db_column(:marketcap) }
  it { is_expected.to have_db_column(:net_income) }
end
