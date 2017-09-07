require 'rails_helper'

describe "search/basic", type: :view do
  let(:cant_find) { false }
  let(:entities) { [] }
  let(:groups) { [] }
  let(:lists) { [] }
  let(:maps) { [] }
  let(:tags) { [] }
  let(:q) { '' }

  before(:each) do
    assign(:cant_find, cant_find)
    assign(:entities, entities)
    assign(:groups, groups)
    assign(:lists, lists)
    assign(:maps, maps)
    assign(:tags, tags)
    assign(:q, q)
    render
  end

  describe 'layout' do
    it 'contains search form and results div' do
      css 'h1', text: 'Search'
      css 'form'
      css 'div.search-results'
    end

    context 'results found' do
      it { is_expected.not_to render_template(partial: '_cantfind') }
    end

    context 'no results found' do
      let(:cant_find) { true }
      it { is_expected.to render_template(partial: '_cantfind') }
    end
  end

  context 'Searching for bufffalo' do
    let(:q) { 'buffalo' }

    context 'nothing found' do
      it 'displays no results found message' do
        css 'strong', text: 'No results found.'
      end
    end

    context 'found a group' do
      let(:groups) { [build(:group)] }

      it 'shows research groups' do
        css 'h3', text: 'Research Groups'
        css 'span.search-result-link'
      end
    end

    context 'found 2 lists (and no groups)' do
      let(:lists) { [build(:list), build(:open_list)] }

      it 'shows list of list links' do
        not_css 'h3', text: 'Research Groups'
        css 'h3', text: 'Lists'
        css 'span.search-result-link', count: 2
      end
    end

    context 'found a map' do
      let(:maps) { [build(:network_map)] }

      it 'shows link to the map' do
        not_css 'h3', text: 'Research Groups'
        not_css 'h3', text: 'List'
        css 'h3', text: 'Maps'
        css 'span.search-result-link', count: 1
      end
    end

    context 'found a entity' do
      let(:entities) { Kaminari.paginate_array([build(:org)]).page(1) }

      it 'shows link to the entity' do
        css 'h3', text: 'Entities'
        css 'span.search-result-link', count: 1
      end
    end

    context 'found a tag' do
      let(:tags) { [build(:oil_tag, id: 123)] }

      it 'shows a link to the tag' do
        css 'h3', text: 'Tags'
        css 'span.search-result-link', count: 1
      end
    end
  end
  
end
