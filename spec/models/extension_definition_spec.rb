require 'rails_helper'

describe ExtensionDefinition, type: :model  do
  it { should have_many(:extension_records) }
  it { should have_many(:entities) }

  it 'should have ID constants' do
    expect(ExtensionDefinition::PERSON_ID).to eql 1
    expect(ExtensionDefinition::ORG_ID).to eql 2
  end

  describe 'person types & org types' do
    it 'returns all person types' do
      expect(ExtensionDefinition).to receive(:where).with(parent_id: 1).once.and_return(double(order: {name: :asc}))
      ExtensionDefinition.person_types
    end

    it 'returns all org types' do
      expect(ExtensionDefinition).to receive(:where).with(parent_id: 2).once.and_return(double(order: {name: :asc}))
      ExtensionDefinition.org_types
    end
  end

  describe 'display_names' do
    it 'returns a memozined hash map' do
      expect(ExtensionDefinition.display_names).to be_a Hash
      expect(ExtensionDefinition.display_names.keys.to_set).to eql ExtensionDefinition.all.map(&:id).to_set
      expect(ExtensionDefinition.display_names.fetch(26)).to eql  "Political Party"
    end
  end
end
