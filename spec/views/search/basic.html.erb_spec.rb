require 'rails_helper'

describe "search/basic", type: :view do
  let(:cant_find) { false }

  before(:each) do
    assign(:cant_find, cant_find)
    render
  end

  describe 'layout' do
    it 'contains search form and results div' do
      css 'form'
      css 'div.search-results'
    end
  end

  context 'results found' do
    it { is_expected.not_to render_template(partial: '_cantfind') }
  end

  context 'no results found' do
    let(:cant_find) { true }
    it { is_expected.to render_template(partial: '_cantfind') }
  end
  
end
