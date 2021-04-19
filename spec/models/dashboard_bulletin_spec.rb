describe DashboardBulletin, type: :model do
  it { is_expected.to have_db_column(:title) }
  it { is_expected.to have_db_column(:color).of_type(:string) }
  it { is_expected.to have_db_index(:created_at) }

  describe 'color validation' do
    context 'with valid color' do
      subject(:bulletin) { build(:dashboard_bulletin, color: '#8d0724') }

      specify { expect(bulletin.valid?).to be true }
    end

    context 'with valid color with extra spaces' do
      subject(:bulletin) { build(:dashboard_bulletin, color: '#5533FF   ') }

      specify { expect(bulletin.valid?).to be true }
    end

    context 'with invalid color' do
      subject(:bulletin) { build(:dashboard_bulletin, color: 'snail') }

      specify { expect(bulletin.valid?).to be false }

      specify do
        bulletin.valid?
        expect(bulletin.errors[:color]).to eq ['Invalid css color: snail']
      end
    end
  end

  describe '#display_color' do
    context 'with non-empty color field' do
      subject(:bulletin) { DashboardBulletin.new(color: '#ccc') }

      specify { expect(bulletin.display_color).to eq '#ccc' }
    end

    context 'with empty color field' do
      subject(:bulletin) { DashboardBulletin.new }

      specify { expect(bulletin.display_color).to eq 'rgba(0, 0, 0, 0.03)' }
    end

    context 'with blank string as color field' do
      subject(:bulletin) { DashboardBulletin.new(color: '') }

      specify { expect(bulletin.display_color).to eq 'rgba(0, 0, 0, 0.03)' }
    end
  end

  describe 'cache clearing' do
    it 'deletes the cache after bullet is destroy' do
      bulletin = create(:dashboard_bulletin)
      expect(Rails.cache).to receive(:delete_matched)
                               .with('*home_dashboard_bulletins*')
                               .once

      bulletin.destroy!
    end
  end
end
