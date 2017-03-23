require 'rails_helper'

describe 'entities/edit.html.erb', type: :view do
  before(:all) do
    @current_user = create(:user, sf_guard_user: create(:sf_guard_user, id: rand(100)))
    @entity = create(:org, last_user_id: @current_user.sf_guard_user.id)
    @person = create(:person, last_user_id: @current_user.sf_guard_user.id)
  end

  describe 'layout for Org' do
    before do
      assign(:entity, @entity)
      assign(:current_user, @user)
      assign(:references, [])
      render
    end

    it 'renders header partial' do
      expect(view).to render_template(partial: '_header', count: 1)
    end

    it 'renders actions partial' do
      expect(view).to render_template(partial: '_actions', count: 1)
    end

    it 'renders actions partial' do
      expect(view).to render_template(partial: '_edit_references_panel', count: 1)
    end

    it 'has one form' do
      css 'form', count: 1
    end

    it 'does not render person_name_form_components' do
      expect(view).not_to render_template(partial: '_person_name_form_components')
    end
  end

  context 'if it is an Person' do
    before do
      assign(:entity, @person)
      assign(:current_user, @user)
      assign(:references, [])
      render
    end

    it 'renders person_name_form_components' do
      expect(view).to render_template(partial: '_person_name_form_components', count: 1)
    end

    it 'renders person_name_form_gender' do
      expect(view).to render_template(partial: '_person_name_form_gender', count: 1)
    end
  end
end
