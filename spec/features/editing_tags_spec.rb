feature "Editing Tags", :tag_helper, type: :feature do
  before do
    TagSpecHelper::TAGS.each { |t| Tag.create!(t) }
  end

  after do
    Tag.remove_instance_variable(:@lookup) if Tag.instance_variable_defined?(:@lookup)
  end

  let(:admin) { create_admin_user }
  let(:normal_user) { create_really_basic_user }
  let(:user) { admin }
  before(:each) { login_as(user, scope: :user) }
  after(:each) { logout(:user) }

  feature 'Admins can edit tag attributes' do
    let(:tag) { Tag.find(1) } # oil
    before(:each) { visit edit_tag_path(tag) }

    it 'displays a form with the tag information' do
      expect(page.status_code).to eq 200
      expect(page).to have_current_path edit_tag_path(tag)
      expect(page).to have_content "Editing Tag:"
      expect(page).to have_content 'oil'
      expect(page).to have_selector 'form.edit_tag'
      expect(page).to have_selector '#delete-this-tag'
    end

    scenario 'Admin can change the description of the tag' do
      fill_in('Description', with: 'prefers profit over people')
      find('form.edit_tag input[name="commit"]').click
      expect(Tag.find(tag.id).description).to eq 'prefers profit over people'

      expect(page).to have_current_path admin_tags_path
      expect(page).to have_selector 'div.alert-success', count: 1
    end

    scenario 'Admin tries to change the tag name to a name that already exists' do
      expect(Tag.find(tag.id).name).to eq 'oil'
      fill_in('Name', with: 'nyc')
      find('form.edit_tag input[name="commit"]').click
      expect(Tag.find(tag.id).name).to eq 'oil'

      expect(page).to have_current_path edit_tag_path(tag)
      expect(page).not_to have_selector 'div.alert-success'
      expect(page).to have_selector 'div.alert-danger', count: 1
    end

    scenario 'Admin wants to delete a tag' do
      find('#delete-this-tag').click
      expect(Tag.count).to eq 2
      expect(page).to have_current_path admin_tags_path
      expect(page).to have_selector 'div.alert-success', count: 1
    end

    context 'user is not an admin' do
      let(:user) { normal_user }
      denies_access
    end
  end
end
