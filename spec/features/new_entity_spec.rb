describe '/entities/new', type: :feature do
  let(:user) { create_editor }

  before { login_as(user, scope: :user) }

  after { logout(:user) }

  describe 'creating a new entity' do
    let(:name) { "#{Faker::Name.first_name} #{Faker::Name.last_name}" }
    let(:blurb) { Faker::Quotes::Shakespeare.hamlet_quote.truncate(200) }

    describe 'linked to add entity with page a name' do
      before { visit '/entities/new?name=exxon' }

      it 'has name field already filled out' do
        successfully_visits_page '/entities/new?name=exxon'
        expect(find('#entity_name').value).to eq 'exxon'
      end
    end

    describe 'when user is an editor' do
      before do
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

    # describe 'when user is not an editor' do
    #   let(:user) { create_user }

    #   let!(:entity_count) { Entity.count }

    #   before do
    #     visit '/entities/new'
    #   end


    #   it 'cannot create a new person' do
    #     successfully_visits_page '/entities/new'

    #     fill_in 'entity_name', with: name
    #     fill_in 'entity_blurb', with: blurb
    #     choose 'Person'
    #     click_button 'Add'

    #     successfully_visits_page '/home/dashboard'

    #     expect(Entity.count).to eq entity_count

    #     expect(page).to have_text 'In order to prevent abuse, new users are restricted from editing for the first hour.'
    #   end
    # end
  end
end
