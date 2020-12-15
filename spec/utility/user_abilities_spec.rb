# frozen_string_literal: true

describe UserAbilities do
  it 'can be initialized nothing' do
    expect { UserAbilities.new }.not_to raise_error
  end

  describe 'responds to blank? and empty?' do
    specify { expect(UserAbilities.new.empty?).to be true }
    specify { expect(UserAbilities.new.blank?).to be true }
    specify { expect(UserAbilities.new(:edit).empty?).to be false }
    specify { expect(UserAbilities.new(:edit).blank?).to be false }
  end

  it 'can be initialized with arguments' do
    expect(UserAbilities.new(:edit, :merge).abilities)
      .to eq Set[:edit, :merge]
  end

  it 'raises error if initalized with known ability' do
    expect { UserAbilities.new(:edit, :fly) }.to raise_error(UserAbilities::InvalidUserAbilitiesSetError)
  end

  describe 'UserAbilities.dump' do
    it 'raises error if called with an object besides UserAbilities' do
      expect { UserAbilities.dump(foo: 'bar') }.to raise_error(ActiveRecord::SerializationTypeMismatch)
    end

    it 'serializes an empty set as nil' do
      expect(UserAbilities.dump(UserAbilities.new)).to be nil
    end

    it 'serializes nil as nil' do
      expect(UserAbilities.dump(nil)).to be nil
    end

    it 'seralizes as comma seperated list' do
      expect(UserAbilities.dump(UserAbilities.new(:edit, :merge, :delete)))
        .to eq 'edit,merge,delete'
    end
  end

  describe 'boolean helper methods' do
    subject(:user_abilities) { UserAbilities.new(*abilities) }

    context 'when an admin' do
      let(:abilities) { [:admin] }

      specify { expect(user_abilities.admin?).to be true }
      specify { expect(user_abilities.editor?).to be true }
      specify { expect(user_abilities.deleter?).to be true }
      specify { expect(user_abilities.merger?).to be true }
      specify { expect(user_abilities.bulker?).to be true }
      specify { expect(user_abilities.matcher?).to be true }
      specify { expect(user_abilities.uploader?).to be true }
    end

    context 'when an editor, deleter, and matcher' do
      let(:abilities) { [:edit, :delete, :match] }

      specify { expect(user_abilities.admin?).to be false }
      specify { expect(user_abilities.editor?).to be true }
      specify { expect(user_abilities.deleter?).to be true }
      specify { expect(user_abilities.merger?).to be false }
      specify { expect(user_abilities.bulker?).to be false }
      specify { expect(user_abilities.lister?).to be false }
      specify { expect(user_abilities.matcher?).to be true }
      specify { expect(user_abilities.uploader?).to be false }
    end

    context 'when an lister' do
      let(:abilities) { [:edit, :list] }

      specify { expect(user_abilities.lister?).to be true }
    end

    context 'when an uploader' do
      let(:abilities) { [:edit, :list, :upload] }

      specify { expect(user_abilities.uploader?).to be true }
    end
  end

  describe 'eql?' do
    it 'is equal when sets have same abilities' do
      expect(UserAbilities.new(:edit, :merge).eql?(UserAbilities.new(:merge, :edit)))
        .to be true
    end

    it 'is not equal when sets have difference abilities' do
      expect(UserAbilities.new(:edit).eql?(UserAbilities.new(:merge, :edit)))
        .to be false
    end

    it 'raises error when compared with invalid class' do
      expect { UserAbilities.new.eql?(Set.new) }.to raise_error(TypeError)
    end
  end

  describe 'to_set' do
    let(:ua) { UserAbilities.new(:merge, :edit) }

    it 'returns @abilities' do
      expect(ua.to_set).to eql ua.abilities
    end

    it 'returns a duplicate set' do
      expect(ua.abilities).not_to be ua.to_set
    end
  end

  describe 'adding and removing' do

    it 'adds new ability' do
      expect(UserAbilities.new(:edit).add(:bulk).abilities)
        .to eq Set[:edit, :bulk]
    end

    it 'adds multiple abilities at once' do
      expect(UserAbilities.new(:edit).add(:edit, :bulk, :merge).abilities)
        .to eq Set[:edit, :bulk, :merge]
    end

    it 'removes an ability' do
      expect(UserAbilities.new(:edit).remove(:edit).abilities)
        .to eql Set.new
    end

    it 'removes multiple abilities at once' do
      expect(UserAbilities.new(:edit, :bulk, :merge).remove(:edit).abilities)
        .to eq Set[:bulk, :merge]
    end

    it 'raises error if called with an unknown ability' do
      expect { UserAbilities.new.add(:dance) }
        .to raise_error(UserAbilities::InvalidUserAbilityError)
    end

    it 'returns new object' do
      user_abilities = UserAbilities.new(:edit)
      new_user_abilities = UserAbilities.new(:edit).add(:bulk)
      expect(new_user_abilities).to be_a UserAbilities
      expect(new_user_abilities.object_id).not_to eq user_abilities.object_id
    end
  end

  describe 'UserAbilities.assert_valid_ability' do
    specify do
      expect { UserAbilities.assert_valid_ability(:flying) }.to raise_error(UserAbilities::InvalidUserAbilityError)
    end

    specify do
      expect { UserAbilities.assert_valid_ability(:edit) }.not_to raise_error
    end
  end

  describe 'UserAbilities.load' do
    it 'deserializes nil as empty set' do
      expect(UserAbilities.load(nil).empty?).to be true
    end

    it 'deserializes comma seperated values' do
      expect(UserAbilities.load('edit,merge,delete').abilities)
        .to eq Set[:edit, :merge, :delete]
    end

    it 'rasies TypeError if not loaded with a string' do
      expect { UserAbilities.load(foo: 'bar') }.to raise_error(TypeError)
    end
  end
end
