require 'rails_helper'

describe 'entities/edit.html.erb', type: :view do
  before(:all) do
    @current_user = create(:user, sf_guard_user: create(:sf_guard_user, id: rand(100)))
    @entity = create(:org, last_user_id: @current_user.sf_guard_user.id)
  end

  describe 'layout' do
    before do
      assign(:entity, @entity)
      assign(:current_user, @user)
      render
    end

    it 'renders header partial' do
      expect(view).to render_template(partial: '_header', count: 1)
    end

    it 'renders actions partial' do
      expect(view).to render_template(partial: '_actions', count: 1)
    end

  end
end
