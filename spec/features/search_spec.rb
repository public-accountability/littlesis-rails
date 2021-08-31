describe 'Search', :sphinx, js: true do
  before do
    setup_sphinx

    create(:finance_tag)
    create(:real_estate_tag)
    create(:nyc_tag)

    create(:entity_org, name: 'apple org').tap do |e|
      e.add_tag('finance')
      e.add_tag('nyc')
    end

    create(:entity_person, name: 'apple person').tap do |e|
      e.add_tag('finance')
      e.add_tag('real-estate')
    end

    create(:entity_org, name: 'banana! corp').tap do |e|
      e.add_tag('nyc')
    end
  end

  after do
    teardown_sphinx
  end

  describe 'searching for bananas' do
    # let(:lists) { [] }

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
      list = create(:open_list, name: 'Green Banana')
      list.add_entity(create(:entity_org))

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
