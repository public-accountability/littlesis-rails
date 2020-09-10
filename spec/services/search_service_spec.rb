describe SearchService do

  it 'raises error if initalized with a blank query' do
    expect { SearchService.new(nil) }.to raise_error(SearchService::BlankQueryError)
    expect { SearchService.new('') }.to raise_error(SearchService::BlankQueryError)
  end

  it 'can be initalized with tag_filter' do
    expect(SearchService.new('foo').tag_filter).to be nil
    expect(SearchService.new('foo', tag_filter: 'bar').tag_filter).to eq 'bar'
  end

  it 'sets page' do
    expect(SearchService.new('foo').page).to eq 1
    expect(SearchService.new('foo', page: 2).page).to eq 2
  end

  it 'removes filler words only when not contained in quotes' do
    expect(SearchService.new('temple of doom').query).to eq 'temple doom'
    expect(SearchService.new('university of california "school of law"').query)
      .to eq 'university california "school of law"'
    expect(SearchService.new('"university of california" school of law').query)
      .to eq '"university of california" school law'
  end

  it 'sets @esacped_query' do
    expect(SearchService.new('@foo').escaped_query).to eq '\\@foo'
  end

  it 'searches tags' do
    expect(Tag).to receive(:search_by_names).with('foo').once
    service = SearchService.new('foo')
    2.times { service.tags }
  end

  it 'searches entities' do
    expect(EntitySearchService).to receive(:new)
                                     .with(query: 'foo', page: 1)
                                     .once
                                     .and_return(double(:search => []))
    SearchService.new('foo').entities
  end

  it 'passes tag filter to entities' do
    expect(EntitySearchService).to receive(:new)
                                     .with(query: 'foo', tags: 'bar', page: 1)
                                     .once
                                     .and_return(double(:search => []))
    SearchService.new('foo', tag_filter: 'bar').entities
  end

  it 'searches lists when not an admin' do
    expect(List).to receive(:search)
                      .with("@(name,description) foo",
                            per_page: 50,
                            with: { is_deleted: false, is_admin: 0 },
                            without: { access: Permissions::ACCESS_PRIVATE, entity_count: 0 })
                      .once

    SearchService.new('foo').lists
  end

  it 'searches lists when user is an admin' do
    expect(List).to receive(:search)
                      .with("@(name,description) foo",
                            per_page: 50,
                            with: { is_deleted: false, is_admin: [0, 1] },
                            without: { access: Permissions::ACCESS_PRIVATE, entity_count: 0})
                      .once

    SearchService.new('foo', admin: true).lists
  end

  it 'searches maps' do
    expect(NetworkMap).to receive(:search)
                            .with("@(title,description,index_data) foo",
                                  per_page: 50,
                                  with: { is_deleted: false, is_private: false })
                            .once

    SearchService.new('foo').maps
  end
end
