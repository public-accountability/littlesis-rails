require 'rails_helper'

describe 'edits/entity.html.erb', type: :view do
  before do
    @sf_user = build(:sf_guard_user)
    @current_user = build(:user, sf_guard_user: @sf_user)
    @entity = build(:person, updated_at: 1.day.ago)
    expect(@entity).to receive(:last_user).twice.and_return(@sf_user)
    assign(:current_user, @current_user)
    assign(:entity, @entity)
    render
  end

  it 'renders header partial' do
    expect(view).to render_template(partial: '_header', count: 1)
  end

  it 'renders actions partial' do
    expect(view).to render_template(partial: '_actions', count: 1)
  end
end
