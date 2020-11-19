feature 'Matching donations', type: :feature, js: true do
  let(:user) { create_admin_user }
  let(:oedipa) { create(:entity_person, name: 'Oedipa Maas') }

  before do
    login_as user, scope: :user
  end

  after do
    logout(:user)
  end

  context 'with a potential donation' do
    let(:pierce) { create(:entity_person, name: 'Pierce Inverarity') }

    before do
      create(
        :os_donation,
        contribid: pierce.id,
        contrib: pierce.name,
        name_first: 'Oedipa',
        name_last: 'Maas',
        city: 'San Narciso',
        state: 'CA',
        employer: 'Tristero'
      )
    end

    scenario 'I can match the donation' do
      visit match_donations_person_path(oedipa)
      expect(page).to have_css('h2', text: 'Match Donations From OpenSecrets.org')

      within '#donations-table' do
        within_row('Pierce Inverarity') do
          expect(page).to have_css('td', text: 'San Narciso, CA')
          first('td').click
        end

        expect(page).to have_css('tr.selected')
      end

      within '.toolbar' do
        click_button 'Match Selected'
      end

      expect(page).to have_css('td.dataTables_empty', text: 'No data available in table')
    end
  end
end
