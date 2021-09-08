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
                                     .with(query: 'foo', page: 1, populate: true)
                                     .once
                                     .and_return(double(:search => []))
    SearchService.new('foo').entities
  end

  it 'passes tag filter to entities' do
    expect(EntitySearchService).to receive(:new)
                                     .with(query: 'foo', tags: 'bar', page: 1, populate: true)
                                     .once
                                     .and_return(double(:search => []))
    SearchService.new('foo', tag_filter: 'bar').entities
  end

  it 'searches lists when not an admin' do
    expect(List).to receive(:search)
                      .with("@(name,description) foo",
                            per_page: 10,
                            populate: true,
                            with: { is_deleted: false, is_admin: 0 },
                            without: { access: Permissions::ACCESS_PRIVATE },
                            order: "is_featured DESC"
                           )
                      .once

    SearchService.new('foo').lists
  end

  it 'searches lists when user is an admin' do
    expect(List).to receive(:search)
                      .with("@(name,description) foo",
                            per_page: 10,
                            populate: true,
                            with: { is_deleted: false, is_admin: [0, 1] },
                            without: { access: Permissions::ACCESS_PRIVATE },
                            order: "is_featured DESC"
                           )
                      .once

    SearchService.new('foo', admin: true).lists
  end

  it 'searches maps' do
    expect(NetworkMap).to receive(:search)
                            .with("@(title,description,index_data) foo",
                                  per_page: 10,
                                  populate: true,
                                  with: { is_deleted: false, is_private: false },
                                  order: "is_featured DESC"
                                 )
                            .once

    SearchService.new('foo').maps
  end

  context 'with featured and non-featured lists' do
    describe 'search', :sphinx do
      before do
        setup_sphinx
        create(:list, name: 'my interesting list', is_featured: false).tap do |l|
          ListEntity.create(list_id: l.id, entity_id: create(:entity_person, name: 'Interesting Person').id)
        end

        create(:list, name: 'some other list', is_featured: true).tap do |l|
          ListEntity.create(list_id: l.id, entity_id: create(:entity_person, name: 'Other Person').id)
        end

        create(:list, name: 'yet another list', is_featured: false).tap do |l|
          ListEntity.create(list_id: l.id, entity_id: create(:entity_person, name: 'Another Person').id)
        end
      end

      after do
        teardown_sphinx
      end

      it 'puts featured lists at the top of the results' do
        results = SearchService.new('list').lists

        expect(results.first.name).to eq 'some other list'
        expect(results.last.is_featured).to be false
      end
    end
  end

  context 'with featured and non-featured maps' do
    describe 'search', :sphinx do
      before do
        setup_sphinx
        create(:network_map, title: 'my interesting map', is_featured: false, user: create(:user))
        create(:network_map_version3, title: 'some other map', is_featured: true, user: create(:user))
        create(:network_map, title: 'yet another map', is_featured: false, user: create(:user))
      end

      after do
        teardown_sphinx
      end

      it 'puts featured maps at the top of the results' do
        results = SearchService.new('map').maps

        expect(results.first.name).to eq 'some other map'
        expect(results.last.is_featured).to be false
      end
    end
  end
end
