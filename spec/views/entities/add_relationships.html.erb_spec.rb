describe 'entities/add_relationship' do
  let(:user) { build(:user) }
  let(:entity) { build(:mega_corp_inc, updated_at: Time.current, last_user: user, id: rand(100)) }

  describe 'layout' do
    before do
      assign(:entity, entity)
      render
    end

    specify { css 'a.entity-name2' }
    specify { css 'h2', :text => "Create a new relationship" }
    specify { css '#add-relationship-page' }

    it { is_expected.to render_template(partial: '_header2') }
    it { is_expected.to render_template(partial: '_explain_categories_modal') }
  end
end
