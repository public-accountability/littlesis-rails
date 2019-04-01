require 'rails_helper'

describe 'EntitySearch' do
  describe 'Entity::Search.search' do
    let(:defaults) do
      { with: { is_deleted: false },
        per_page: 15,
        page: 1,
        select: '*, weight() * (link_count + 1) AS link_weight',
        order: 'link_weight DESC' }
    end

    let(:arg1) { '@(name,aliases) someone' }

    it 'calls Entity.search with defaults' do
      expect(Entity).to receive(:search).with(arg1, defaults)
      Entity::Search.search 'someone'
    end

    it 'accept hash as second arg to overrides defaults' do
      expect(Entity).to receive(:search).with(arg1, defaults.merge(per_page: 5))
      Entity::Search.search 'someone', num: 5
    end

    it 'will allow the page option to be modified' do
      expect(Entity).to receive(:search).with(arg1, defaults.merge(page: 2))
      Entity::Search.search 'someone', page: 2
    end
  end

  describe 'entity_with_summary' do
    it 'returns hash with summary field' do
      e = build(:person, summary: 'i am a summary')
      h = Entity::Search.entity_with_summary(e)
      expect(h).to include :summary => 'i am a summary'
    end
  end

  describe 'entity_no_summary' do
    it 'returns hash without summary field' do
      e = build(:person, summary: 'i am a summary')
      h = Entity::Search.entity_no_summary(e)
      expect(h).to be_a Hash
      expect(h).not_to include :summary => 'i am a summary'
    end
  end
end
