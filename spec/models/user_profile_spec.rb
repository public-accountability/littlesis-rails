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
  end
end
