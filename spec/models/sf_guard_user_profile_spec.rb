require 'rails_helper'

describe SfGuardUserProfile do
  before(:all) { DatabaseCleaner.start }
  after(:all) { DatabaseCleaner.clean }

  describe 'validations' do
    before(:all) { @sf_guard_user = create(:sf_guard_user) }
    subject { build(:sf_guard_user_profile, user_id: @sf_guard_user.id) }

    it { should validate_presence_of(:email) }
    it { should validate_uniqueness_of(:email).case_insensitive }
    it { should validate_presence_of(:name_first) }
    it { should validate_presence_of(:home_network_id) }

    context 'Validating reason field' do
      subject(:profile) { build(:sf_guard_user_profile, user_id: @sf_guard_user.id) }

      context 'valid when reason is 2 words' do
        before { profile.reason = 'doing research' }
        specify { expect(profile.valid?).to be true }
      end

      context 'not valid when when reason is 1 word' do
        before { profile.reason = 'toolazytowritewords' }
        specify { expect(profile.valid?).to be false }
      end

      context 'not valid when reason is nil' do
        before { profile.reason = nil }
        specify { expect(profile.valid?).to be false }
      end

      context 'when reason is nil and persisted' do
        it 'is valid' do
          profile = create(:sf_guard_user_profile, user_id: @sf_guard_user.id)
          profile.update_column(:reason, nil)
          expect(profile.reason).to be nil
          expect(profile.valid?).to be true
        end
      end
    end
  end
end
