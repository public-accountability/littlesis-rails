describe '/entities/new', type: :feature do
  let(:user) { create_basic_user }

  before { login_as(user, scope: :user) }

  after { logout(:user) }

  describe 'linked to add entity with page a name' do
    let(:url) { '/entities/new?name=exxon' }

    before { visit url }

    it 'has name field already filled out' do
      successfully_visits_page url
      expect(find('#entity_name').value).to eql 'exxon'
    end
  end

  describe 'creating a new entity' do
    let(:name) { "#{Faker::Name.first_name} #{Faker::Name.last_name}" }
    let(:blurb) { Faker::Quotes::Shakespeare.hamlet_quote.truncate(200) }

    context 'when user is confirmed over 60 minutes  ago' do
      before do
        user.update_columns :confirmed_at => 61.minutes.ago
        visit '/entities/new'
      end

      it 'can create a new person' do
        successfully_visits_page '/entities/new'

        fill_in 'entity_name', with: name
        fill_in 'entity_blurb', with: blurb
        choose 'Person'
        click_button 'Add'

        expect(page.status_code).to eq 200
        expect(Entity.last.name).to eql name
        expect(page.current_path).to include '/person/'
        expect(page.current_path).to include '/edit'
      end
    end

    context 'when user is confirmed less than 60 minutes ago' do
      before do
        user.update_columns :confirmed_at => 50.minutes.ago
        visit '/entities/new'
      end

      let!(:entity_count) { Entity.count }

      it 'cannot create a new person' do
        successfully_visits_page '/entities/new'

        fill_in 'entity_name', with: name
        fill_in 'entity_blurb', with: blurb
        choose 'Person'
        click_button 'Add'

        successfully_visits_page '/home/dashboard'

        expect(Entity.count).to eq entity_count

        expect(page).to have_text 'In order to prevent abuse, new users are restricted from editing for the first hour.'
      end
    end
  end
end
