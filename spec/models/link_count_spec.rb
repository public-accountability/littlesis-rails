require 'rails_helper'

describe 'entity#update_link_count' do

  it 'updates link count for entity with no relationships' do
    e = create(:person)
    expect(Entity.find(e.id).link_count).to eq 0
    e.update_link_count
    expect(Entity.find(e.id).link_count).to eq 0
  end

  it 'updates link count after a new relationship is created' do
    e = create(:person)
    expect(Entity.find(e.id).link_count).to eq 0
    Relationship.create!(entity: e, related: create(:person), category_id: 12)
    e.update_link_count
    expect(Entity.find(e.id).link_count).to eq 1
  end

end

describe 'updating link count' do
end
  
