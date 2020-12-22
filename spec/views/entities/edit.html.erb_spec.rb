describe 'entities/edit.html.erb', type: :view do
  let(:current_user) { create_basic_user }
  let(:entity) { create(:entity_org, last_user_id: current_user.id) }
  let(:person) { create(:entity_person, last_user_id: current_user.id) }

  describe 'layout for Org' do
    before do
      assign(:entity, entity)
      assign(:current_user, current_user)
      assign(:references, [])
      render
    end

    specify do
      expect(view).to render_template(partial: '_header', count: 1)
      expect(view).to render_template(partial: '_actions', count: 1)
      expect(view).to render_template(partial: '_reference_widget', count: 1)
      css 'form', count: 4
      expect(view).not_to render_template(partial: '_person_name_form_components')
      expect(view).to render_template(partial: '_edit_errors')
      not_css 'div.alert'
    end

    context 'when entity has one error' do
      let(:error_entity) do
        build(:org,
              id: rand(1000), updated_at: Time.current,
              last_user_id: 1,
              start_date: 'bad date')
      end

      before do
        error_entity.valid?
        assign(:entity, error_entity)
        assign(:current_user, current_user)
        assign(:references, [])
        render
      end

      specify do
        expect(view).to render_template(partial: '_edit_errors')
        css 'div.alert', count: 1
      end
    end
  end

  describe 'layout for person' do
    before do
      assign(:entity, person)
      assign(:current_user, current_user)
      assign(:references, [])
      render
    end

    specify do
      expect(view).to render_template(partial: '_person_name_form_components', count: 1)
      expect(view).to render_template(partial: '_person_name_form_gender', count: 1)
    end
  end
end
