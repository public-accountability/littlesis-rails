feature 'Adding a new references to entities', type: :feature, js: :true do
  let(:user) do
    create_basic_user.tap { |user| user.add_ability!(:upload) }
  end

  let(:entity) { create(:entity_person) }

  let(:url) { Faker::Internet.url }

  before do
    login_as user, scope: :user
    visit references_person_path(entity)
  end

  scenario 'Adding a url' do
    find('#add-new-refernce-link').click

    within '#add-reference-modal' do
      within '#reference-form' do
        fill_in 'data_url', with: url
        fill_in 'data_name', with: 'example link'
      end
      click_on 'Submit'
    end

    expect(entity.reload.documents.last.url).to eq url
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

    # expect(entity.reload.documents.last.url).to eq url
  end
end
