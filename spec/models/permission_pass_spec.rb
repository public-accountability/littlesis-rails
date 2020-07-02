require 'rails_helper'

RSpec.describe PermissionPass, type: :model do
  let(:user) { create(:admin_user) }
  let(:pass) { build(:permission_pass, creator: user, abilities: UserAbilities.new(:bulk, :match)) }

  context 'when creating a permission pass' do
    it 'returns abilities as a UserAbilities object' do
      expect(pass.abilities).to be_a UserAbilities
    end

    it 'records the specified abilities' do
      expect(pass.abilities.bulker?).to be true
      expect(pass.abilities.matcher?).to be true
      expect(pass.abilities.lister?).to be false
    end

    it 'has a random token generated automatically' do
      expect(pass.token.present?).to be true
    end

    it 'is valid from creation unless otherwise specified' do
      expect(pass.valid_from.to_i).to eq pass.created_at.to_i
    end

    it 'has a creator' do
      expect(pass.creator).to be_a User
    end

    it 'cannot have a nonsense date range' do
      pass.update(valid_from: 1.week.from_now, valid_to: 1.week.ago)
      expect(pass.valid?).to be false
    end

    it 'requires short validity period' do
      pass.update(valid_from: Time.current, valid_to: 100.years.from_now)
      expect(pass.valid?).to be false
    end

    it 'cannot be used to grant admin rights' do
      pass.update(abilities: UserAbilities.new(:admin))
      expect(pass.valid?).to be false
    end

    it 'cannot be used to grant nonsense abilities' do
      expect { pass.update(abilities: UserAbilities.new(:president)) }
        .to raise_error(UserAbilities::InvalidUserAbilitiesSetError)
    end
  end

  describe '#current?' do
    let(:current_pass) { create(:permission_pass, creator: user, valid_from: 1.hour.ago, valid_to: 2.hours.from_now) }
    let(:expired_pass) { create(:permission_pass, creator: user, valid_from: 12.months.ago, valid_to: 12.months.ago + 3.days) }
    let(:future_pass) { create(:permission_pass, creator: user, valid_from: 2.weeks.from_now, valid_to: 3.weeks.from_now) }

    it 'is true when valid_to is in the future and valid_from is in the past' do
      expect(current_pass.current?).to be true
    end

    it 'is false when valid_to is in the past' do
      expect(expired_pass.current?).to be false
    end

    it 'is false when valid_from is in the future' do
      expect(future_pass.current?).to be false
    end
  end

  describe 'permissions' do
    let(:user) { create(:user) }

    it 'requires the creator to be an admin' do
      expect(pass.valid?).to be false
      expect(pass.errors.full_messages).to include "Creator must be an admin"
    end
  end
end
