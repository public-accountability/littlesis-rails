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
      expect(ExtensionDefinition).to receive(:where).with(parent_id: 1).once
      ExtensionDefinition.person_types
    end

    it 'returns all org types' do
      expect(ExtensionDefinition).to receive(:where).with(parent_id: 2).once
      ExtensionDefinition.org_types
    end
  end

end
