require 'rails_helper'

describe Business do
  it { is_expected.to have_db_column(:assets) }
  it { is_expected.to have_db_column(:marketcap) }
  it { is_expected.to have_db_column(:net_income) }
  it { is_expected.to have_db_column(:crd_number).of_type(:integer) }

  describe 'with_crd_number' do
    before do
      create(:entity_org).add_extension('Business', crd_number: Faker::Number.unique.number(5).to_i)
      create(:entity_org).add_extension('Business')
    end

    specify do
      expect(Business.with_crd_number.count).to eq 1
    end
  end
end
