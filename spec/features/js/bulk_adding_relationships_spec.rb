feature 'Bulk-adding relationships', type: :feature, js: true do
  let(:user) { create_collaborator }
  let(:oedipa) { create(:entity_person, name: 'Oedipa Maas') }

  before do
    # Stub out actual Entity creation to avoid db deadlock problem upon form submit
    allow(Entity).to receive(:create).and_return(true)

    login_as user, scope: :user
    visit relationships_bulk_add_path(entity_id: oedipa.id)
  end

  after do
    logout(:user)
  end

  context 'with valid data' do
    let(:csv) { Rails.root.join('spec', 'testdata', 'bulk_add_relationships', 'generic.csv') }

    let(:related_entities) do
      CSV.parse(csv.read, headers: true).map do |row|
        build(:entity_person, name: row["name"], primary_ext: row["primary_ext"], blurb: row["blurb"]).tap do |related|
          build(:generic_relationship, entity: oedipa, related: related)
        end
      end
    end

    scenario 'I can upload a CSV' do
      expect(page).to have_css('h1', text: 'Bulk Add Relationships for Oedipa Maas')
      expect(page).to have_css('#relationship-cat-select')

      select 'Generic', from: 'relationship-cat-select'

      fill_in 'reference-url', with: Faker::Internet.url
      fill_in 'reference-name', with: 'The Crying of Lot 49'

      within '.table-editable' do
        expect(page).to have_css('table th', text: 'Blurb', visible: :visible)
        expect(page).to have_css('tbody tr', count: 1)

        attach_file('csv-file', csv)

        expect(page).to have_css('tbody tr', count: 3)

        related_entities.each do |entity|
          within_row(entity.name) do
            expect(page).to have_css('td', text: entity.blurb)
            expect(page).to have_css('td', text: entity.primary_ext)
          end
        end
      end

      click_button 'Upload Data'

      expect(page).to have_css('h4', text: 'Processing')
    end

    scenario 'I can delete rows' do
      expect(page).to have_css('h1', text: 'Bulk Add Relationships for Oedipa Maas')

      select 'Generic', from: 'relationship-cat-select'

      fill_in 'reference-url', with: Faker::Internet.url
      fill_in 'reference-name', with: 'The Crying of Lot 49'

      within '.table-editable' do
        attach_file('csv-file', csv)

        expect(page).to have_css('tbody tr', count: 3)

        first('.table-remove').click

        expect(page).to have_css('tbody tr', count: 2)
      end
    end
  end

  context 'with bad data' do
    let(:csv) { Rails.root.join('spec', 'testdata', 'bulk_add_relationships', 'bad_data.csv') }

    let(:related_entities) do
      CSV.parse(csv.read, headers: true).map do |row|
        build(:entity_person, name: row["name"], primary_ext: row["primary_ext"], blurb: row["blurb"]).tap do |related|
          build(:generic_relationship, entity: oedipa, related: related)
        end
      end
    end

    # autocomplete system was changed
    xscenario 'I can correct the data' do
      expect(page).to have_css('h1', text: 'Bulk Add Relationships for Oedipa Maas')
      expect(page).to have_css('#relationship-cat-select')

      select 'Generic', from: 'relationship-cat-select'

      fill_in 'reference-url', with: Faker::Internet.url
      fill_in 'reference-name', with: 'The Crying of Lot 49'

      within '.table-editable' do
        attach_file('csv-file', csv)

        related_entities.each do |entity|
          within_row(entity.name) do
            expect(page).to have_css('td', text: entity.blurb)
            expect(page).to have_css('td', text: entity.primary_ext)
          end
        end
      end

      click_button 'Upload Data'

      expect(page).to show_danger('Failed to find or create entity')
      expect(page).to have_css('h4', text: '0 Relationships were created / 1 Errors occured')
      expect(page).to have_text 'click here to repopulate the table with the relationships that failed'
      find('#results .cursor-pointer').click

      within '.table-editable' do
        related_entities.each do |entity|
          within_row(entity.name) do
            expect(page).to have_css('td', text: entity.blurb)
            expect(page).to have_css('td', text: entity.primary_ext)
          end

          name_cell = find('.ui-autocomplete-input', text: entity.name)

          # Delete and retype the name
          entity.name.length.times { name_cell.send_keys(:backspace) }
          name_cell.send_keys('Mucho Maas')
        end
      end

      click_button 'Upload Data'

      expect(page).to have_css('h4', text: 'Processing')
    end
  end
end
