require 'rails_helper'

describe Org do
  it { should belong_to(:entity) }

  describe '#set_entity_name' do
    let(:name) { Faker::Company.name }
    it 'sets entity name to eql org name after creating' do
      entity = Entity.create!(primary_ext: 'Org', name: name)
      expect(entity.org.name).to eql name
    end
  end
end
