describe 'Entity Search', :sphinx, type: :request do
  before do
    setup_sphinx

    TagSpecHelper::TAGS.each { |t| Tag.create!(t) }

    entities = [
      create(:entity_org, name: 'apple org'),
      create(:entity_person, name: 'apple person'),
      create(:entity_org, name: 'banana! corp')
    ]

    entities[0].add_tag('oil')
    entities[0].add_tag('nyc')
    entities[1].add_tag('oil')
    entities[1].add_tag('finance')
    entities[2].add_tag('nyc')
  end

  after do
    teardown_sphinx
  end

  describe 'searching by keyword' do
    it 'finds two entities and results json' do
      get '/search/entity', params: { q: 'apple' }
      expect(response).to have_http_status :ok
      expect(json.length).to eq 2
      expect(json.map { |e| e['name'] }.to_set).to eql Set['apple org', 'apple person']
    end

    it 'can set limit option' do
      get '/search/entity', params: { q: 'apple', num: '1' }
      expect(response).to have_http_status :ok
      expect(json.length).to eq 1
    end
  end

  describe 'Limiting search to person or org' do
    it 'limits results to people' do
      get '/search/entity', params: { q: 'apple', ext: 'Person' }
      expect(response).to have_http_status :ok
      expect(json.length).to eq 1
      expect(json.first['name']).to eql 'apple person'
    end

    it 'limits result to org' do
      get '/search/entity', params: { q: 'apple', ext: 'Org' }
      expect(response).to have_http_status :ok
      expect(json.length).to eq 1
      expect(json.first['name']).to eql 'apple org'
    end
  end

  describe 'Limiting search by tag' do
    it 'returns both apple entities when searching for oil tag' do
      get '/search/entity', params: { q: 'apple', tags: 'oil' }
      expect(response).to have_http_status :ok
      j = JSON.parse(response.body)
      expect(j.length).to eq 2
      expect(j.map { |e| e['name'] }.to_set).to eql ['apple org', 'apple person'].to_set
    end

    it 'returns only apple org when searching for nyc tag' do
      get '/search/entity', params: { q: 'apple', tags: 'nyc' }
      expect(response).to have_http_status :ok
      j = JSON.parse(response.body)
      expect(j.length).to eq 1
      expect(j.map { |e| e['name'] }).to eq ['apple org']
    end

    it 'returns only apple person when searching for finance tag by name' do
      get '/search/entity', params: { q: 'apple', tags: 'finance' }
      expect(response).to have_http_status :ok
      j = JSON.parse(response.body)
      expect(j.length).to eq 1
      expect(j.map { |e| e['name'] }).to eq ['apple person']
    end

    it 'returns only apple person when searching for finance tag by id' do
      get '/search/entity', params: { q: 'apple', tags: '3' }
      expect(response).to have_http_status :ok
      j = JSON.parse(response.body)
      expect(j.length).to eq 1
      expect(j.map { |e| e['name'] }).to eq ['apple person']
    end
  end
end
