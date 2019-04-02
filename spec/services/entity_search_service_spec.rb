# frozen_string_literal: true

require 'rails_helper'

describe EntitySearchService do
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
end
