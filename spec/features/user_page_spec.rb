feature 'User Pages' do
  let(:current_user) { create_editor }
  let(:user_for_page) { create_editor }
  let(:admin) { create_admin_user }
  let(:user) { current_user }
  let(:entity) { create(:entity_person) }

  before do
    login_as(user, scope: :user)
    entity.update!(is_current: true, last_user_id: user_for_page.id)
  end

  after { logout(user) }

  describe 'User Page' do
    scenario 'visiting the page via the user name' do
      visit "/users/#{user_for_page.username}"
      successfully_visits_page "/users/#{user_for_page.username}"
      page_has_selector 'h1', text: user_for_page.username
      page_has_selector 'small', text: "member since #{user.created_at.strftime('%B %Y')}"
    end

    scenario 'visiting a user page as any logged into user' do
      visit "/users/#{user_for_page.id}"
      successfully_visits_page "/users/#{user_for_page.id}"
      page_has_selector 'h1', text: user_for_page.username
      page_has_selector 'div', text: user_for_page.about_me
    end
  end

  describe 'User Edits Page' do
    let(:url) { "/users/#{user_for_page.username}/edits" }

    context 'when logged in as another user' do
      let(:user) { current_user }
      before { visit url }
      denies_access
    end

    context 'when logged in as admin' do
      let(:user) { admin }
      before { visit url }
      specify { successfully_visits_page(url) }
    end

    context 'when logged in as the user' do
      let(:entities) { Array.new(2) { create(:entity_org) } }
      let(:user) { user_for_page }

      context 'with 2 edits' do
        with_versioning do
          before do
            entities.each { |e| e.update!(blurb: Faker::Creature::Dog.meme_phrase) }
            entities.each { |e| e.versions.last.update_columns(whodunnit: user_for_page.id.to_s) }
            visit url
          end

          scenario 'page has table of recent edits' do
            successfully_visits_page(url)
            page_has_selector 'table#user-edits-table'
            page_has_selector '#user-edits-table tbody tr', count: 2
          end
        end
      end
    end
  end
end
