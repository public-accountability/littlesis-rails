# frozen_string_literal: true

require 'rails_helper'

describe EntitySearchService, :tag_helper do
  seed_tags

  let(:defaults) do
    { with: { is_deleted: false },
      per_page: 15,
      page: 1,
      select: '*, weight() * (link_count + 1) AS link_weight',
      order: 'link_weight DESC' }
  end

  let(:search_term) { "@(name,aliases) foo" }
  let(:search_term_with_notes) { "@(name,aliases,notes) foo" }

  it 'searching with default options' do
    expect(Entity).to receive(:search).with(search_term, defaults).once
    EntitySearchService.new(query: 'foo').search
  end

  it 'can override per_page option' do
    expect(Entity).to receive(:search).with(search_term, defaults.merge(per_page: 5)).once
    EntitySearchService.new(query: 'foo', num: 5).search
  end

  it 'can override per_page option and add additional fields' do
    expect(Entity).to receive(:search).with(search_term_with_notes, defaults.merge(per_page: 5)).once
    EntitySearchService.new(query: 'foo', num: 5, fields: %w[name aliases notes]).search
  end

  it 'raises error when search is left blank' do
    expect { EntitySearchService.new.search }.to raise_error(ArgumentError)
  end

  it 'accepts a single tag as string' do
    expect(EntitySearchService.new(tags: 'nyc').options[:tags]).to eq [2]
  end

  it 'accepts a mutiple tags as array' do
    expect(EntitySearchService.new(tags: ['oil', 'nyc']).options[:tags]).to eq [1, 2]
  end

  it 'accepts a mutiple tags as string' do
    expect(EntitySearchService.new(tags: 'oil,nyc').options[:tags]).to eq [1, 2]
  end

  it 'accepts a mutiple tags as string (as integers)' do
    expect(EntitySearchService.new(tags: '1,3').options[:tags]).to eq [1, 3]
  end

  it 'ignores tags that do not exist' do
    expect(EntitySearchService.new(tags: '1,4').options[:tags]).to eq [1]
  end

  it 'warns if tag does not exists' do
    expect(Rails.logger).to receive(:warn).with("[EntitySearchService]: unknown tag: foo").once
    expect(EntitySearchService.new(tags: 'oil,foo').options[:tags]).to eq [1]
  end

  describe 'search_options_with' do
    it 'skips tags if empty' do
      expect(EntitySearchService.new.send(:search_options_with)).to eq(is_deleted: false)
      expect(EntitySearchService.new(tags: '100').send(:search_options_with)).to eq(is_deleted: false)
    end

    it 'includes tags in query' do
      expect(EntitySearchService.new(tags: 'oil,nyc').send(:search_options_with))
        .to eq(is_deleted: false, tag_ids: [1, 2])

      expect(EntitySearchService.new(tags: '2').send(:search_options_with))
               .to eq(is_deleted: false, tag_ids: [2])
    end
  end

  describe 'entity_with_summary' do
    it 'returns hash with summary field' do
      e = build(:person, summary: 'i am a summary')
      h = EntitySearchService.entity_with_summary(e)
      expect(h).to include :summary => 'i am a summary'
    end
  end

  describe 'entity_no_summary' do
    it 'returns hash without summary field' do
      e = build(:person, summary: 'i am a summary')
      h = EntitySearchService.entity_no_summary(e)
      expect(h).to be_a Hash
      expect(h).not_to include :summary => 'i am a summary'
    end
  end
end
