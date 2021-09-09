describe 'search/basic', type: :view do
  let(:entities) { [] }
  let(:groups) { [] }
  let(:lists) { [] }
  let(:maps) { [] }
  let(:tags) { [] }
  let(:q) { '' }
  let(:no_results) { false }
  let(:user_signed_in) { false }

  before do
    assign(:entities, entities)
    assign(:groups, groups)
    assign(:lists, lists)
    assign(:maps, maps)
    assign(:tags, tags)
    assign(:q, q)
    assign(:no_results, no_results)
    allow(view).to receive(:user_signed_in?).and_return(user_signed_in)
    render
  end

  describe 'layout' do
    it 'contains search form and results div' do
      css 'h1', text: 'Search'
      css 'form'
      css 'div.search-results'
    end

    describe 'results found' do
      let(:q) { 'xyz' }
      let(:entities) { Kaminari.paginate_array([build(:org)]).page(1) }

      it { is_expected.not_to render_template(partial: '_cantfind') }
    end

    describe 'no results found' do
      let(:q) { 'xyz' }
      let(:no_results) { true }

      specify do
        css 'strong', text: "No results found."
      end
    end
  end

  describe 'Searching for buffalo' do
    let(:q) { 'buffalo' }

    describe 'found 2 lists (and no groups)' do
      let(:lists) { [build(:list), build(:open_list)] }

      it 'shows list of list links' do
        not_css 'h3', text: 'Research Groups'
        css 'h3', text: 'Lists'
        css 'span.search-result-link', count: 2
      end
    end

    describe 'found a map' do
      let(:maps) { [build(:network_map)] }

      it 'shows link to the map' do
        not_css 'h3', text: 'Research Groups'
        not_css 'h3', text: 'List'
        css 'h3', text: 'Maps'
        css 'span.search-result-link', count: 1
      end
    end

    describe 'found a entity' do
      let(:entities) { Kaminari.paginate_array([build(:org)]).page(1) }

      it 'shows link to the entity' do
        css 'h3', text: 'Entities'
        css 'span.search-result-link', count: 1
      end
    end

    describe 'found a tag' do
      let(:tags) { [build(:oil_tag, id: 123)] }

      it 'shows a link to the tag' do
        css 'h3', text: 'Tags'
        css 'span.search-result-link', count: 1
      end
    end
  end
end
