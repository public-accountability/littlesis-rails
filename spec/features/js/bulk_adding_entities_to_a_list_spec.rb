feature 'Bulk-adding entities to a list', type: :feature, js: true do
  let(:list_owner) { create_basic_user }
  let(:list) { create(:list, name: 'All people who have ever lived', creator_user_id: list_owner.id, last_user_id: list_owner.id) }
  let(:csv) { Rails.root.join('spec', 'testdata', 'list-bulk-add-csvs', 'new-entities.csv') }

  let(:entities) do
    CSV.parse(csv.read, headers: true).map do |row|
      build(:entity_person, name: row["name"], primary_ext: row["primary_ext"], blurb: row["blurb"])
    end
  end

  before do
    login_as list_owner, scope: :user
    visit new_list_entity_association_path(list)
  end

  after do
    logout(:user)
  end

  context 'with new entities' do
    before do
      allow(Entity).to receive(:search).and_return([])
    end

    scenario 'no duplications are flagged' do
      expect(page).to have_css('#bulk-add-header', text: "Add entities to #{list.name}")

      within '#upload-container' do
        attach_file('Upload CSV', csv)
      end

      expect(page).to have_css('#bulk-add-table')

      within '#reference-container' do
        fill_in 'Name', with: 'Some people who have lived'
        fill_in 'Url', with: Faker::Internet.url
        find('.url .reference-input').send_keys :enter
      end

      within '#bulk-add-table' do
        entities.each do |entity|
          expect(page).to have_field 'Name', with: entity.name
          expect(page).to have_field 'Entity Type', with: entity.primary_ext
          expect(page).to have_field 'Description', with: entity.blurb
        end
      end

      expect(page).not_to have_css('.alert-icon[title="resolve duplicates"]')
    end

    scenario 'I can delete rows' do
      expect(page).to have_css('#bulk-add-header', text: "Add entities to #{list.name}")

      within '#upload-container' do
        attach_file('Upload CSV', csv)
      end

      expect(page).to have_css('#bulk-add-table')

      within '#bulk-add-table' do
        expect(page).to have_css('tbody tr', count: 2)

        first('.delete-icon[title="delete row"]').click

        expect(page).to have_css('tbody tr', count: 1)
      end
    end

    scenario 'entity rows are validated' do
      expect(page).to have_css('#bulk-add-header', text: "Add entities to #{list.name}")

      within '#upload-container' do
        attach_file('Upload CSV', csv)
      end

      expect(page).to have_css('#bulk-add-table')

      within '#bulk-add-table tbody tr:first-child' do
        fill_in 'Name', with: 'Prince'
        fill_in 'Description', with: 'purple'
      end

      expect(page).to have_css('.cell-input.error-alert[value="Prince"]')
    end
  end

  context 'with duplicate entities' do
    before do
      allow(Entity).to receive(:search).and_return(entities.each(&:save))
    end

    xscenario 'I can resolve duplications' do
      expect(page).to have_css('#bulk-add-header', text: "Add entities to #{list.name}")

      within '#upload-container' do
        attach_file('Upload CSV', csv)
      end

      expect(page).to have_css('#bulk-add-table')

      within '#reference-container' do
        fill_in 'Name', with: 'Some people who have lived'
        fill_in 'Url', with: Faker::Internet.url
        find('.url .reference-input').send_keys :enter
      end

      within '#bulk-add-table' do
        entities.each do |entity|
          expect(page).to have_field 'Name', with: entity.name
          expect(page).to have_field 'Entity Type', with: entity.primary_ext
          expect(page).to have_field 'Description', with: entity.blurb
        end
      end

      expect(page).to have_css('.alert-icon[title="resolve duplicates"]')
      duplicate_count = all('.alert-icon[title="resolve duplicates"]').count

      first('.alert-icon[title="resolve duplicates"]').click

      expect(page).to have_css('.popover-header', text: 'Similar entities already exist')

      within '.resolver-popover' do
        find('.filter-option-inner-inner', text: 'Pick an existing entity...').click
        first('.dropdown-item').click
        find('.resolver-picker-btn').click
      end

      expect(all('.alert-icon[title="resolve duplicates"]').count).to eq duplicate_count - 1
    end
  end

  context 'without a reference' do
    before do
      allow(Entity).to receive(:search).and_return([])
    end

    scenario 'there are warnings and I cannot submit the form' do
      expect(page).to have_css('#bulk-add-header', text: "Add entities to #{list.name}")

      within '#upload-container' do
        attach_file('Upload CSV', csv)
      end

      expect(page).to have_css('#bulk-add-table')

      within '#bulk-add-table' do
        entities.each do |entity|
          expect(page).to have_field 'Name', with: entity.name
          expect(page).to have_field 'Entity Type', with: entity.primary_ext
          expect(page).to have_field 'Description', with: entity.blurb
        end
      end

      expect(page).to have_css('.reference-input.error-alert')
      expect(page).to have_css('button#bulk-submit-button[disabled]')
    end
  end
end
