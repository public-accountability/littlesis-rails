describe Org do
  it { is_expected.to belong_to(:entity) }

  describe '#set_entity_name' do
    let(:name) { Faker::Company.name }

    it 'sets entity name to eql org name after creating' do
      entity = Entity.create!(primary_ext: 'Org', name: name)
      expect(entity.org.name).to eq name
    end
  end

  describe 'name_variations' do
    specify do
      entity = create(:entity_org, name: 'Foo LLC')
      entity.aliases.create!(name: 'Foo, LLC')
      entity.aliases.create!(name: 'Bar LLC')
      expect(entity.org.name_variations.to_set).to eq ['foo llc', 'bar llc'].to_set
    end
  end
end
