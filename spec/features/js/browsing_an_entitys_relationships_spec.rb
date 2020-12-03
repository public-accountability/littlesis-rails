feature "Browsing an entity's relationships", type: :feature, js: true do
  let(:user) { create_basic_user }
  let(:oedipa) { create(:entity_person, name: 'Oedipa Maas') }
  let(:mucho) { create(:entity_person, name: 'Mucho Maas') }
  let(:pierce) { create(:entity_person, name: 'Pierce Inverarity') }

  before do
    create(:family_relationship, entity: oedipa, related: mucho, start_date: '1960-00-00', end_date: '1965-00-00')
    create(:donation_relationship, entity: pierce, related: oedipa, start_date: '1958-00-00', end_date: '1959-00-00')
    visit datatable_entity_path(oedipa)
  end

  scenario 'sorting relationships by date' do
    expect(page).to have_css('#entity-name', text: 'Oedipa Maas')
    expect(page).to have_css('h3', text: 'Relationships')

    within '#relationships-table' do
      within(:xpath, "//tbody/tr[1]") do
        expect(page).to have_css('.entity-link', text: 'Mucho Maas')
      end

      within(:xpath, "//tbody/tr[2]") do
        expect(page).to have_css('.entity-link', text: 'Pierce Inverarity')
      end

      find('th', text: "Date(s)").click

      within(:xpath, "//tbody/tr[1]") do
        expect(page).to have_css('.entity-link', text: 'Pierce Inverarity')
      end

      within(:xpath, "//tbody/tr[2]") do
        expect(page).to have_css('.entity-link', text: 'Mucho Maas')
      end
    end
  end

  scenario 'filtering relationships by category' do
    expect(page).to have_css('#entity-name', text: 'Oedipa Maas')
    expect(page).to have_css('h3', text: 'Relationships')

    within '#relationships-table' do
      within_row('Mucho Maas') do
        expect(page).to have_css('a', text: 'Family')
      end

      within_row('Pierce Inverarity') do
        expect(page).to have_css('a', text: 'Donation')
      end
    end

    within '#relationships-filters' do
      select 'Family', from: 'relationships-category'
    end

    within '#relationships-table' do
      expect(page).to have_css('.entity-link', text: 'Mucho Maas')
      expect(page).not_to have_css('.entity-link', text: 'Pierce Inverarity')
    end

    within '#relationships-filters' do
      select 'Donation', from: 'relationships-category'
    end

    within '#relationships-table' do
      expect(page).not_to have_css('.entity-link', text: 'Mucho Maas')
      expect(page).to have_css('.entity-link', text: 'Pierce Inverarity')
    end
  end
end
