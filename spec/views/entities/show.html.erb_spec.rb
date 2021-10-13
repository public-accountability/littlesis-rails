describe 'entities/show.html.erb' do
  let(:user) { create_basic_user }

  let(:entity) do
    build(:org, last_user_id: 1, updated_at: 1.day.ago, org: build(:organization))
  end

  describe 'switching tabs' do
    before do
      assign(:active_tab, active_tab)
      assign(:entity, entity)
      allow(entity).to receive(:similar_entities).and_return([])
      render
    end

    context 'when on relationships tab' do
      let(:active_tab) { 'relationships' }

      it { is_expected.to render_template('entities/_relationships') }
    end

    context 'when on interlocks tab' do
      let(:active_tab) { 'interlocks' }

      it { is_expected.to render_template('entities/_interlocks') }
    end
  end

  describe 'relationships tab' do
    before do
      assign(:active_tab, 'relationships')
      allow(entity).to receive(:search).and_return([])
    end

    describe 'header' do
      let(:e) do
        with_versioning_for(user) do
          create(:entity_org, name: 'test org', blurb: 'testing')
        end
      end

      before do
        assign(:entity, e)
        assign(:similar_entities, [])
        render
      end

      it 'has correct header' do
        expect(rendered).to have_css('#entity-name')
        expect(rendered).to have_css('#entity-name a', :count => 1)
        expect(rendered).to have_css('#entity-name', :text => 'test org')
        expect(rendered).to have_css('#entity-blurb-wrapper', :text => 'testing')
      end

      specify 'update at' do
        expect(rendered).to have_css('#entity-edited-history', :text => 'ago')
      end
    end

    describe 'with importer permission' do
      let(:user) { create(:user, abilities: UserAbilities.new(:edit, :bulk)) }
      let(:e) { create(:entity_person, last_user: user) }

      before do
        assign(:entity, e)
        assign(:current_user, user)
        sign_in user
        render
      end

      specify do
        expect(rendered).to have_css('#actions a', :count => 6)
        expect(rendered).to have_css('a', :text => 'add bulk')
      end
    end

    describe 'tabs' do
      let(:e) { create(:entity_org, updated_at: Time.current, last_user: user) }

      before do
        assign(:entity, e)
        assign(:current_user, user)
        render
      end

      specify do
        expect(rendered).to have_css '.button-tabs span.active', :count => 1
        expect(rendered).to have_css '.button-tabs span a', :text => 'Relationships', :count => 1
        expect(rendered).to have_css '.button-tabs span.active a', :text => 'Relationships', :count => 1
        expect(rendered).not_to have_css '.button-tabs span.active a', :text => 'Interlocks'
        expect(rendered).to have_css '.button-tabs span.active a', :text => 'Relationships', :count => 1
        expect(rendered).not_to have_css '.button-tabs span.active a', :text => 'Interlocks'
        expect(rendered).to have_css '.button-tabs span a', :text => 'Interlocks', :count => 1
        expect(rendered).to have_css '.button-tabs span a', :text => 'Giving', :count => 1
        # expect(rendered).to have_css '.button-tabs span a', :text => 'Political', :count => 1
        expect(rendered).to have_css '.button-tabs span a', :text => 'Data', :count => 1
      end
    end
  end
end
