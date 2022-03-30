describe UserProfile, type: :model do
  it { is_expected.to have_db_column(:user_id).of_type(:integer) }
  it { is_expected.to have_db_column(:name).of_type(:text) }
  it { is_expected.to have_db_column(:reason).of_type(:text) }
  it { is_expected.to have_db_column(:location).of_type(:string) }
  it { is_expected.to belong_to(:user) }

  describe 'Validating reason field' do
    subject(:profile) { build(:user_profile, user: build(:user)) }

    context 'when reason is 2 words' do
      before { profile.reason = 'doing research' }

      specify { expect(profile.valid?).to be true }
    end

    context 'when when reason is 1 word' do
      before { profile.reason = 'toolazytowritewords' }

      specify { expect(profile.valid?).to be false }
    end

    context 'when reason is nil' do
      before { profile.reason = nil }

      specify { expect(profile.valid?).to be false }
    end

    context 'when reason is nil and persisted' do
      it 'is valid' do
        profile = create(:user_profile, user: create_really_basic_user)
        profile.update_column(:reason, nil)
        expect(profile.reason).to be nil
        expect(profile.valid?).to be true
      end
    end
  end
end
