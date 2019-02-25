require 'rails_helper'

describe ExternalDataset, type: :model do
  it { is_expected.to have_db_column(:name).of_type(:string) }
  it { is_expected.to have_db_column(:row_data).of_type(:text) }
  it { is_expected.to have_db_column(:matched).of_type(:boolean) }
  it { is_expected.to have_db_column(:match_data).of_type(:text) }

  it do
    is_expected.to validate_inclusion_of(:name).in_array(ExternalDataset::DATASETS)
  end

end
