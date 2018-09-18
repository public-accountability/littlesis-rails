require 'rails_helper'

describe 'entities/political.html.erb' do
  before(:all) do
    @sf_user = build(:sf_guard_user, username: 'X')
    @user = build(:user, sf_guard_user: @sf_user)
    @person = build(:person, updated_at: Time.now, last_user: @sf_user, id: rand(1000))
    @org = build(:mega_corp_inc, updated_at: Time.now, last_user: @sf_user, id: rand(1000))
  end

  describe 'renders partials' do
    context 'common to all' do
      before do
        assign(:entity, @org)
        render
      end

      it 'renders header' do
        expect(view).to render_template(partial: 'entities/_header')
      end

      it 'renders actions' do
        expect(view).to render_template(partial: 'entities/_actions')
      end

      it 'renders summary' do
        expect(view).to render_template(partial: 'entities/_summary')
      end
    end # common
  end # Paritals

  describe 'layout' do
    context 'entity is a person' do
      before do
        assign(:entity, @person)
        render
      end

      it 'has header' do
        expect(rendered).to have_css '#entity-name'
      end

      it 'has actions' do
        expect(rendered).to have_css '#entity-edited-history'
        expect(rendered).to have_css '#actions a', :count => 3
      end

      it 'has tabs' do
        expect(rendered).to have_css '.button-tabs span a', :count => 5
      end

      it 'has active Political tab' do
        expect(rendered).to have_css '.button-tabs span.active a', :text => 'Political', :count => 1
      end

      it 'has political contribution div' do
        expect(rendered).to have_css '#political-contributions', :count => 1
      end

      it 'has political pie chart div' do
        expect(rendered).to have_css '#political-pie-chart', :count => 1
      end

      it 'has pie info div with spans' do
        expect(rendered).to have_css '#pie-info', :count => 1
        expect(rendered).to have_css '#pie-info p span', :count => 6
      end
    end # context: Person

    context 'entity is a org' do
      before do
        assign(:entity, @org)
        render
      end

      it 'has Top donors title' do
        css 'h3', text: 'Top donors'
      end
    end
  end # layout
end
