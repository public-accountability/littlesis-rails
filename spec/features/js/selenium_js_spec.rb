# Example feature spec to demonstrate JS interactions via Chromedriver
feature 'Selenium JS', type: :feature, js: true do
  let(:admin) { create_admin_user }

  before do
    login_as admin, scope: :user
  end

  after do
    logout(:user)
  end

  context 'with a list of people' do
    let(:list) { create(:list, name: 'The Crying of Lot 49', creator_user_id: admin.id, last_user_id: admin.id) }
    let(:oedipa) { create(:entity_person, name: 'Oedipa Maas') }
    let(:mucho) { create(:entity_person, name: 'Mucho Maas') }
    let(:pierce) { create(:entity_person, name: 'Pierce Inverarity') }

    before do
      [oedipa, mucho, pierce].each do |person|
        ListEntity.create!(list_id: list.id, entity_id: person.id)
      end
    end

    context 'when visiting the list members page' do
      before do
        visit members_list_path(list)
      end

      it 'displays the list members in the datatable JS table' do
        expect(page).to have_css('.entity-link', count: 3)

        [oedipa, mucho, pierce].each do |person|
          within '#datatable-table' do
            expect(page).to have_css('.entity-link', text: person.name)
          end
        end
      end
    end
  end
end
