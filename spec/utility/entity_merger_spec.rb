require 'rails_helper'

describe 'Merging Entities' do
 
  # def entity_merge(source:, dest:)
  # end

  it 'can only merge entities that have the same primary extension'
  it 'sets the "merged_id" fields of the merged entity to be the id of the merged entity'
  it 'marks the merged entity as deleted'

  context 'extensions' do
    it 'adds new extensions to the destination entity'
    it 'updates fields on the destination entity if they are nil'
  end

  context 'contact info' do
    it 'adds addresses to the destination entity'
    it 'adds emails to destination entity'
    it 'adds phone numbers to the destination entity'
  end

  context 'lists' do
    it 'adds the destination entity to the lists of the source entity'
    it 'removes the source entity from it\'s lists'
  end

  it 'transfers images from the source to the destination entity'

  it 'transfers aliases (if they do not already exist)'

  it 'transfers references'

  it 'transfers articles'

  context 'os donations' do
    it 'unmatches the os donations from the source entity'
    it 'matches those donations on the destination entity'
  end

  context 'ny donations' do
    it 'unmatches the ny donations from the source entity'
    it 'matches those donations on the destination entity'
  end

  context 'relationships' do
    context 'when a relationship exists on the source but not the destination' do
      it 'creates a new reference on the destination'
      it 'deletes the relationship from the source'
      it 'transfers the references from the relationship'
    end

    context 'when a relationship exists on both' do
      it 'does not create a new relationship'
      it 'deletes the relationship from the source'
      it 'updates fields on the existing relationship if the are null'
      it 'copies references from the source relationship'
    end
  end
end

