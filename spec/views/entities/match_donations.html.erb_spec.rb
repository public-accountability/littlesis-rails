describe 'entities/match_donations.html.erb' do
  let(:user) { create_basic_user }
  let(:corp) { create(:entity_org, name: 'mega corp') }
  let(:entity) { create(:entity_person, updated_at: Time.current, last_user: user) }

  describe 'layout' do
    before do
      Relationship.create!(entity: entity, related: corp, description1: 'Overlord', category_id: 1)
      assign(:entity, entity)
      allow(view).to receive(:current_user).and_return(double(:admin? => false))
      render
    end

    it 'has header, actions, and table' do
      expect(rendered).to have_css '#entity-name'
      # actions
      expect(rendered).to have_css '#entity-edited-history'
      expect(rendered).to have_css '#actions a', :count => 3
      expect(rendered).to have_css 'table#donations-table'
    end

    describe 'About Sidebar' do
      it 'has sidebar container' do
        expect(rendered).to have_css '#about-sidebar'
      end

      it 'has name' do
        expect(rendered).to have_css '#about-sidebar h3', :text => 'Human Being'
      end

      it 'has position' do
        expect(rendered).to have_css '.row p strong', :text => 'Positions'
        expect(rendered).to have_css '.row p', :text => 'mega corp'
      end

      it 'does not have Education' do
        expect(rendered).not_to have_css '.row p strong', :text => 'Education'
      end

      it 'does not have Family' do
        expect(rendered).not_to have_css '.row p strong', :text => 'Family'
      end
    end
  end
end
