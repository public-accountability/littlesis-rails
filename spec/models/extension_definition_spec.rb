describe ExtensionDefinition, type: :model do
  it { is_expected.to have_many(:extension_records) }
  it { is_expected.to have_many(:entities) }

  describe 'ID constants' do
    specify { expect(ExtensionDefinition::PERSON_ID).to eq 1 }
    specify { expect(ExtensionDefinition::ORG_ID).to eq 2 }
  end

  describe 'person types & org types' do
    it 'returns all person types' do
      expect(ExtensionDefinition.person_types.count).to eq 9
    end

    it 'returns all org types' do
      expect(ExtensionDefinition.org_types.count).to eq 28
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
end
