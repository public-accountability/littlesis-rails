# frozen_string_literal: true

require 'rails_helper'

describe UserAbilities do
  it 'can be initialized nothing' do
    expect(UserAbilities.new.empty?).to be true
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
