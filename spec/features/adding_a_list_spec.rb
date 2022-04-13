feature "adding an new list", type: :feature do
  let(:user) { create_editor }
  let(:list_name) { "#{Faker::Company.name} staff" }
  let(:short_description) { Faker::Company.catch_phrase }
  let(:url) { Faker::Internet.unique.url }
  let(:url_name) { Faker::Company.bs }

  before do
    login_as(user, scope: :user)
    visit new_list_path
  end

  scenario 'visiting the "add a list page"' do
    successfully_visits_page(new_list_path)
    page_has_selector 'h1', text: "Add a list"
    page_has_selectors '#ref_url', '#ref_name'
    expect(page).not_to have_selector '#list-config-access-buttons'
    expect(page).not_to have_selector "#list-admin-settings-container"
  end

  scenario 'creating a new list' do
    fill_in 'list_name', :with => list_name
    fill_in 'list_short_description', :with => short_description
    fill_in 'ref_url', :with => url
    fill_in 'ref_name', :with => url_name
    click_button 'Add'

    successfully_visits_page(list_path(List.last) + '/members')

    expect(page).not_to have_selector "#error_explanation"

    list = List.last
    reference = Reference.last

    expect(list.access).to eq Permissions::ACCESS_PRIVATE
    expect(list.name).to eql list_name
    expect(list.creator_user_id).to eq user.id
    expect(list.last_user_id).to eq user.id
    expect(list.short_description).to eq short_description
    expect(reference.referenceable_id).to eq list.id
    expect(reference.referenceable_type).to eq 'List'
    expect(reference.document.url).to eq url
    expect(reference.document.name).to eq url_name
  end

  scenario 'attempting to create a new list with invalid reference values' do
    list_count = List.count
    reference_count = Reference.count
    fill_in 'list_name', :with => list_name
    fill_in 'list_short_description', :with => short_description
    fill_in 'ref_url', :with => 'not a url'
    fill_in 'ref_name', :with => url_name

    click_button 'Add'

    expect(page).to have_selector "#error_explanation"
    expect(page.find("#error_explanation")).to have_text '"not a url" is not a valid url'

    expect(List.count).to eq list_count
    expect(Reference.count).to eq reference_count
  end

  context 'when user is restricted' do
    let(:user) { create_restricted_user }

    it 'does not create list unless user can edit' do
      successfully_visits_page '/home/dashboard'
    end
  end
end
