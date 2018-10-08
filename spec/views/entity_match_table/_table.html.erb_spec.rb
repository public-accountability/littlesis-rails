require "rails_helper"

describe 'partial: entity_match_table/_table.html.erb', type: :view do
  let(:locals) { {} }

  before do
    render partial: 'entity_match_table/table.html.erb', locals: locals
  end

  context 'with model NyFiler' do
    let(:locals) { { model: :NyFiler } }

    specify { css 'table', count: 1 }
    specify { css 'th', count: 3 }
  end
end
