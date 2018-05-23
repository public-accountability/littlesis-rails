require 'rails_helper'

describe 'search/basic', type: :view do
  let(:entities) { [] }
  let(:groups) { [] }
  let(:lists) { [] }
  let(:maps) { [] }
  let(:tags) { [] }
  let(:q) { '' }
  let(:user_signed_in) { false }

  before do
    assign(:entities, entities)
    assign(:groups, groups)
    assign(:lists, lists)
    assign(:maps, maps)
    assign(:tags, tags)
    assign(:q, q)
    allow(view).to receive(:user_signed_in?).and_return(user_signed_in)
    render
  end

  describe 'layout' do
    it 'contains search form and results div' do
      css 'h1', text: 'Search'
      css 'form'
      css 'div.search-results'
    end

    context 'results found' do
      let(:q) { 'xyz' }
      let(:entities) { Kaminari.paginate_array([build(:org)]).page(1) }
      it { is_expected.not_to render_template(partial: '_cantfind') }
    end

    context 'no results found' do
      let(:q) { 'xyz' }
      it { is_expected.to render_template(partial: '_cantfind') }
    end
  end

  context 'Searching for buffalo' do
    let(:q) { 'buffalo' }

    context 'nothing found' do
      it 'displays no results found message' do
        css 'strong', text: 'No results found.'
        css 'h4', text: "Can't find something that should be on LittleSis?"
      end

      context 'user signed in' do
        let(:user_signed_in) { true }

        it 'has button to add it' do
          css 'a.btn', text: 'Add It'
          expect(rendered).not_to include 'to add it yourself!'
        end
      end

      context 'user not signed in' do
        it 'suggests you sign in and add it yourself' do
          expect(rendered).to include 'to add it yourself!'
          not_css 'a.btn', text: 'Add It'
        end
      end
    end

    context 'found a group' do
      let(:groups) { [build(:group)] }

      it 'shows research groups' do
        css 'h3', text: 'Research Groups'
        css 'span.search-result-link'
        expect(rendered).not_to include 'to add it yourself!'
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
