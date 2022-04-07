describe 'Entity References', type: :feature, js: :true do
  let(:user) do
    create_collaborator
  end

  let(:entity) { create(:entity_person) }

  let(:url) { Faker::Internet.url }

  before do
    login_as user, scope: :user
    visit references_person_path(entity)
  end

  scenario 'Adding a url' do
    expect(page.find('table[data-entity-references-table-target="table"] tbody tr').text).to eq 'No data available in table'

    find('#add-new-refernce-link').click

    within '#add-reference-modal' do
      within '#reference-form' do
        fill_in 'data_url', with: url
        fill_in 'data_name', with: 'example link'
      end
      click_on 'Submit'
    end

    expect(entity.reload.documents.last.url).to eq url
    expect(page.all('table[data-entity-references-table-target="table"] tbody tr').count).to eq 1
    expect(page.find('table[data-entity-references-table-target="table"] tbody tr td:first-child').text).to include 'example link'
  end

  scenario 'Uploading a primary source document' do
    find('#add-new-refernce-link').click

    within '#add-reference-modal' do
      within '#reference-form' do
        attach_file 'data_primary_source_document', Rails.root.join('spec/testdata/example.png')
        fill_in 'data_name', with: 'field notes'
      end
      click_on 'Submit'
    end

    entity.reload.documents.last.tap do |document|
      expect(document.name).to eq 'field notes'
      expect(document.ref_type).to eq 'primary_source'
      expect(document.primary_source_document.attached?).to be true
    end
  end
end
