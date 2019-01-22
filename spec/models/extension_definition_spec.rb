require 'rails_helper'

describe ExtensionDefinition, type: :model do
  it { is_expected.to have_many(:extension_records) }
  it { is_expected.to have_many(:entities) }

  describe 'ID constants' do
    specify { expect(ExtensionDefinition::PERSON_ID).to eq 1 }
    specify { expect(ExtensionDefinition::ORG_ID).to eq 2 }
  end

  describe 'person types & org types' do
    it 'returns all person types' do
      expect(ExtensionDefinition.person_types.count).to eq 10
    end

    it 'returns all org types' do
      expect(ExtensionDefinition.org_types.count).to eq 29
    end
  end

  it 'has Academic Research Institute' do
    expect(ExtensionDefinition.find(38).name).to eql 'ResearchInstitute'
  end

  it 'has Government Advisory Body' do
    expect(ExtensionDefinition.find(39).name).to eql 'GovernmentAdvisoryBody'
  end

  it 'has Elite Consensus' do
    expect(ExtensionDefinition.find(40).name).to eql 'EliteConsensus'
  end

  it 'has Stockbroker' do
    expect(ExtensionDefinition.find(41).name).to eql 'Stockbroker'
  end

  describe 'display_names' do
    it 'returns a memozined hash map' do
      expect(ExtensionDefinition.display_names).to be_a Hash
      expect(ExtensionDefinition.display_names.keys.to_set).to eql ExtensionDefinition.all.map(&:id).to_set
      expect(ExtensionDefinition.display_names.fetch(26)).to eq 'Political Party'
    end
  end
end
