require 'rails_helper'

describe Alias, type: :model do
  it { should belong_to(:entity) }
  it { should validate_length_of(:name).is_at_most(200) }
  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:entity_id) }

  it 'trim whitespace from name before validation' do
    a = build(:alias, name: ' company name ', entity_id: rand(100))
    expect(a.valid?).to be true
    expect(a.name).to eq 'company name'
  end

  describe '#make_primary' do
    it 'returns true if the element is already the primary alias' do
      expect(build(:alias, is_primary: true).make_primary).to be true
    end

    it 'removes is_primary from current primary alias & makes this one primary' do
      org = create(:org)
      original_primary_a = org.aliases[0]
      expect(original_primary_a.is_primary?).to eql true
      new_a = org.aliases.create(name: 'other name')
      expect(org.primary_alias).to eq original_primary_a
      expect(new_a.make_primary).to be true
      expect(org.primary_alias).to eq new_a
      expect(Alias.find(original_primary_a.id).is_primary?).to eql false
    end

    it 'changes the name of the entity' do
      org = create(:org, name: 'original name')
      new_a = org.aliases.create(name: 'other name')
      expect(org.name).to eql 'original name'
      expect(new_a.make_primary).to be true
      expect(org.name).to eql 'other name'
    end
  end

  describe 'name_regex' do
    it 'returns regex if name parser can generate one' do
      expect(build(:alias, name: 'xyz').name_regex).to be nil
      expect(build(:alias, name: 'alice the cat').name_regex).to be_a Regexp
    end
  end
end
