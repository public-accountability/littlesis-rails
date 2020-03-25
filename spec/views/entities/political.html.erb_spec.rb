describe 'entities/political.html.erb', type: :view do
  let!(:sf_user) { create(:sf_guard_user, username: 'X') }
  let!(:person) { create(:person, updated_at: Time.current, last_user: sf_user, id: rand(1000)) }
  let!(:org) { create(:mega_corp_inc, updated_at: Time.current, last_user: sf_user, id: rand(1000)) }

  describe 'renders partials' do
    before do
      assign(:entity, org)
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
  end # Partials

  describe 'layout' do
    context 'when entity is a person' do
      before do
        assign(:entity, person)
        render
      end

      it 'has header' do
        expect(rendered).to have_css '#entity-name'
      end

      it 'has actions' do
        expect(rendered).to have_css '#entity-edited-history'
        expect(rendered).to have_css '#actions a', count: 3
      end

      it 'has tabs' do
        expect(rendered).to have_css '.button-tabs span a', count: 5
      end

      it 'has active political tab' do
        expect(rendered).to have_css '.button-tabs span.active a', text: 'Political', count: 1
      end

      it 'has political pie chart div' do
        expect(rendered).to have_css '#political-pie-chart', count: 1
      end

      it 'has pie info div with spans' do
        expect(rendered).to have_css '#pie-info', count: 1
        expect(rendered).to have_css '#pie-info p span', count: 6
      end
    end # context: Person

    context 'when entity is a org' do
      before do
        assign(:entity, org)
        render
      end

      it 'has top donors title' do
        css 'h3', text: 'Top donors'
      end
    end
  end # layout
end
