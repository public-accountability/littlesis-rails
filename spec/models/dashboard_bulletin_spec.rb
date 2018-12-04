require 'rails_helper'

describe DashboardBulletin, type: :model do
  it { is_expected.to have_db_column(:markdown) }
  it { is_expected.to have_db_column(:title) }
  it { is_expected.to have_db_column(:color).of_type(:string) }
  it { is_expected.to have_db_index(:created_at) }

  describe '#color' do
    context 'with non-empty color field' do
      subject(:bulletin) { DashboardBulletin.new(color: '#ccc') }

      specify { expect(bulletin.color).to eq '#ccc' }
    end

    context 'with empty color field' do
      subject(:bulletin) { DashboardBulletin.new }

      specify { expect(bulletin.color).to eq 'rgba(0, 0, 0, 0.03)' }
    end

    context 'with blank string as color field' do
      subject(:bulletin) { DashboardBulletin.new(color: '') }

      specify { expect(bulletin.color).to eq 'rgba(0, 0, 0, 0.03)' }
    end
  end
end
