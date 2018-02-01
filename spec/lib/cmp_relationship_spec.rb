require 'rails_helper'

describe Cmp::CmpRelationship do
  describe 'initialize' do
    it 'sets @org'
  end

  describe 'cmp_person' do
    context 'CmpEntity already exists in the database' do
      it 'returns the associated entity'
    end

    context 'Found a potential matching person' do
      it 'returns match'
    end

    context 'found no match' do
      it 'creates a new entity'
    end
  end
end
