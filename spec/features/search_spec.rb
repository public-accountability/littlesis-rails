describe 'Search', :sphinx, js: true do
  before do
    setup_sphinx

    create(:finance_tag)
    create(:real_estate_tag)
    create(:nyc_tag)

    entities = [
      create(:entity_org, name: 'apple org'),
      create(:entity_person, name: 'apple person'),
      create(:entity_org, name: 'banana! corp')
    ]

    entities[0].add_tag('finance')
    entities[0].add_tag('nyc')
    entities[1].add_tag('finance')
    entities[1].add_tag('real-estate')
    entities[2].add_tag('nyc')
  end

  after do
    teardown_sphinx
  end

  describe 'searching for bananas' do
    let(:lists) { [create(:open_list, name: 'Green Bananas')] }

    it 'finds a single entity' do
      visit '/search?q=banana'
      expect(page.all('.entity-search-result').length).to eq 1
      expect(page).not_to have_selector 'h3', text: 'Lists'
      expect(page).not_to have_selector 'a', class: 'tag'
    end

    it 'finds two entities' do
      visit '/search?q=apple'
      expect(page.all('.entity-search-result').length).to eq 2
    end

    it 'Finds entity and list' do
      expect(List).to receive(:search).once.and_return(lists)
      visit '/search?q=banana'
      expect(page.all('.entity-search-result').length).to eq 1
      expect(page).to have_selector 'h3', text: 'Lists'
    end
  end

  describe 'filter by tag' do
    it 'can filter by tag' do
      expect(List).not_to receive(:search)
      visit '/search?q=apple&tags=nyc'
      expect(page.all('.entity-search-result').length).to eq 1
      expect(page).to have_selector 'a', class: 'tag', text: 'nyc'
    end

    it 'return error when tag does not exist' do
      visit '/search?q=apple&tags=fruit'
      expect(page).not_to have_selector 'h3', text: 'Entities'
      # expect(page.status_code).to eq 400
    end
  end
end
