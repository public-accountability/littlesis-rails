require 'rails_helper'

describe 'edits/entity.html.erb', type: :view do
  before do
    @sf_user = build(:sf_guard_user)
    @current_user = build(:user, sf_guard_user: @sf_user)
    @entity = build(:person, updated_at: 1.day.ago)
    expect(@entity).to receive(:last_user).twice.and_return(@sf_user)
    assign(:current_user, @current_user)
    assign(:entity, @entity)
    assign(:versions, [build(:entity_version)])
    assign(:relationship_changes, [build(:relationship_version)])
    expect(view).to receive(:paginate).twice
    render
  end

  it 'renders header partial' do
    expect(view).to render_template(partial: '_header', count: 1)
  end

  it 'renders actions partial' do
    expect(view).to render_template(partial: '_actions', count: 1)
  end

  it 'has two tables' do
    css 'table', count: 2
  end

  it 'shows version' do
    expect(rendered).to match '<td>update</td>'
    expect(rendered).to match '<strong>blurb:'
    expect(rendered).to match 'original -> updated blurb'
  end

  it 'shows relationship changes ' do
    expect(rendered).to match '<strong>start_date:'
    expect(rendered).to match 'nil -> 2000-01-01'
  end
end
