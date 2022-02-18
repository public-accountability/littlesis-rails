# frozen_string_literal: true

describe EntitySearchService do
  let(:defaults) do
    { with: { is_deleted: false },
      per_page: 15,
      page: 1,
      populate: false,
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

  describe 'tags' do
    before do
      Tag.create!(TagSpecHelper::OIL_TAG)
      Tag.create!(TagSpecHelper::NYC_TAG)
    end

    it 'accepts a single tag as string' do
      expect(EntitySearchService.new(query: 'x', tags: 'nyc').options[:tags]).to eq [2]
    end

    it 'accepts a mutiple tags as array' do
      expect(EntitySearchService.new(query: 'x', tags: ['oil', 'nyc']).options[:tags]).to eq [1, 2]
    end

    it 'accepts a mutiple tags as string' do
      expect(EntitySearchService.new(query: 'x', tags: 'oil,nyc').options[:tags]).to eq [1, 2]
    end

    it 'accepts a mutiple tags as string (as integers)' do
      expect(EntitySearchService.new(query: 'x', tags: '1,2').options[:tags]).to eq [1, 2]
    end

    it 'ignores tags that do not exist' do
      expect(EntitySearchService.new(query: 'x', tags: '1,4').options[:tags]).to eq [1]
    end

    it 'warns if tag does not exists' do
      expect(Rails.logger).to receive(:warn).with("[EntitySearchService]: unknown tag: foo").once
      expect(EntitySearchService.new(query: 'x', tags: 'oil,foo').options[:tags]).to eq [1]
    end

    it 'includes tags in query' do
      expect(EntitySearchService.new(query: 'x', tags: 'oil,nyc').search_options[:with_all]).to eq(tag_ids: [1, 2])
      expect(EntitySearchService.new(query: 'x', tags: '2').search_options[:with_all]).to eq(tag_ids: [2])
    end
  end

  describe 'search_options' do
    let(:list_id) { rand(1_000) }
    let(:excluded_ids) { Array.new(4) { rand(10_000) } }

    it 'skips tags if empty' do
      expect(EntitySearchService.new(query: 'x').search_options[:with_all]).to be_nil
      expect(EntitySearchService.new(query: 'x', tags: '100').search_options[:with_all]).to be_nil
    end

    it 'does not contain option without when exclude_list is empty' do
      expect(EntitySearchService.new(query: 'x').search_options[:without]).to be_nil
    end

    it 'ignores excluded entities when exclude_list is set' do
      expect(ListEntity).to receive(:where)
                              .with(list_id: list_id)
                              .and_return(double(:pluck => excluded_ids))

      search_options = EntitySearchService.new(query: 'x', exclude_list: list_id).search_options

      expect(search_options[:without]).to eq(sphinx_internal_id: excluded_ids)
    end

  end

  describe "searching for a entity by with it's id" do
    let(:entity_id) { rand(1_000).to_s }

    it 'bypasses sphinx and directly find the entity' do
      expect(Entity).to receive(:find).with(entity_id).and_return(instance_double('Entity'))
      expect(Entity).not_to receive(:search)
      search = EntitySearchService.new(query: entity_id).search
      expect(search).to be_a Kaminari::PaginatableArray
      expect(search.length).to eq 1
    end
  end

  describe 'can filtering by tags', :sphinx do
    before do
      Tag.remove_instance_variable(:@lookup) if Tag.instance_variable_defined?(:@lookup)
      setup_sphinx
      create(:nyc_tag)

      create(:entity_org, name: 'apple org').tap do |e|
        e.add_tag('nyc')
      end

      create(:entity_person, name: 'apple person')
    end

    after do
      teardown_sphinx
    end

    it 'finds 2 entities' do
      expect(EntitySearchService.new(query: "apple").search.length).to eq 2
    end

    it 'finds 1 entities when filtering by nyc tag' do
      expect(EntitySearchService.new(query: "apple", tags: "nyc").search.length).to eq 1
    end
  end
end
