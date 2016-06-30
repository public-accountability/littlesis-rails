require 'rails_helper'

describe List do
  it 'includes SoftDelete' 
  it 'includes cacheable'
  it 'includes Referenceable'
  it 'validates name' do
    l = List.new
    expect(l).not_to be_valid
    l.name = "bad politicians"
    expect(l).to be_valid
  end
  context "active relationships" do
    it 'joins entities via ListEntity' do
      list = create(:list)
      inc = create(:mega_corp_inc)
      llc = create(:mega_corp_llc)
      # Every time you create an entity you create a ListEntity because all entites
      # are in a network and all networks are lists joined via the list_entities table.
      # This is why there are 2 list_entities to start with.
      expect(ListEntity.count).to eql(2)
      ListEntity.find_or_create_by(list_id: list.id, entity_id: inc.id)
      ListEntity.find_or_create_by(list_id: list.id, entity_id: llc.id)
      expect(ListEntity.count).to eql(4)
      expect(list.list_entities.count).to eql(2)
    end
  end
end

