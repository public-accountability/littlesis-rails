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

    it 'has two forms' do
      css 'form', count: 2
    end

    it 'does not render person_name_form_components' do
      expect(view).not_to render_template(partial: '_person_name_form_components')
    end

    it 'renders edit errors partial' do
      expect(view).to render_template(partial: '_edit_errors')
    end

    it 'has no alerts' do
      not_css 'div.alert'
    end
  end

  context 'when entity has one error' do
    before do
      @bad_entity = build(:org, id: rand(1000), updated_at: Time.now,
                          last_user_id: @current_user.sf_guard_user.id, start_date: 'bad date')
      @bad_entity.valid?
      assign(:entity, @bad_entity)
      assign(:current_user, @user)
      assign(:references, [])
      render
    end

    it 'renders edit errors partial' do
      expect(view).to render_template(partial: '_edit_errors')
    end

    it 'has one alert' do
      css 'div.alert', count: 1
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
