require "rails_helper"

describe 'Search', :sphinx, :tag_helper do
  seed_tags

  before(:all) do
    setup_sphinx do
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
  end

  after(:all) do
    teardown_sphinx { delete_entity_tables }
  end

  describe 'searching for banana' do
    it 'finds a single entity' do
      visit '/search?q=banana'
      expect(page.status_code).to eq 200
      expect(page.all('.entity-search-result').length).to eq 1
    end
  end

end
