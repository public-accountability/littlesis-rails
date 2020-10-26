describe 'Entity Requests', type: :request do
  include EntitiesHelper

  let(:person) { create(:entity_person, start_date: '2000-01-01', blurb: nil) }
  let(:user) { create_basic_user }

  before(:each) { login_as(user, :scope => :user) }
  after(:each) { logout(:user) }

  describe 'creating many entities' do
    let(:entities) { Array.new(2) { build(:random_entity) } }
    let(:request) { lambda { post '/entities/bulk', params: payload } }
    let(:payload) do
      { data: entities.map { |e| { type: 'entities', attributes: e.attributes } } }
    end

    context 'with insufficient permissions' do
      let(:entities) { Array.new(Entity::BULK_LIMIT + 1) { build(:random_entity) } }

      it 'returns 401 with an error message' do
        expect { request.call }.to change { Entity.count }.by(0)
        expect(response).to have_http_status 401
        expect(json)
          .to eql('errors' => ['title' => Exceptions::UnauthorizedBulkRequest.new.message])
      end
    end

    context 'with valid payload' do
      it 'returns 201 with a collection of entities with new ids appended' do
        expect { request.call }.to change { Entity.count }.by(2)
        expect(response).to have_http_status 201
        expect(json).to eql(Api.as_api_json(Entity.last(2)))
      end
    end

    context 'with improperly-formatted payload' do
      let(:payload) do
        {
          data: [
            { type: 'entities', foo: 'bar' }
          ]
        }
      end

      it 'returns 400 with an error message' do
        expect { request.call }.to change { Entity.count }.by(0)
        expect(response).to have_http_status 400
        expect(json).to eql EntitiesController::ERRORS[:create_bulk]
      end
    end

    context 'with invalid entity attributes' do
      let(:payload) do
        {
          data: [
            { type: 'entities', attributes: { is_admin: true } }
          ]
        }
      end

      it 'returns 400 with an error message' do
        expect { request.call }.to change { Entity.count }.by(0)
        expect(response).to have_http_status 400
        expect(json).to eql EntitiesController::ERRORS[:create_bulk]
      end
    end
  end # creating many entities

  describe 'creating an entity' do
    let(:params) do
      {
        entity: {
          name: 'John Henry',
          blurb: '',
          primary_ext: 'Person'
        }
      }
    end

    let(:new_entity_request) { -> { post '/entities', params: params } }

    it 'creates a new entity' do
      expect(&new_entity_request).to change { Entity.count }.by(1)
    end

    it 'sets blurb to nil if blank' do
      new_entity_request.call
      entity = Entity.last
      expect(entity.name).to eql 'John Henry'
      expect(entity.blurb).to eql nil
    end
  end

  describe 'updating an entity' do
    let(:new_start_date) { '1900-01-01' }
    let(:url) { Faker::Internet.url }
    let(:params) do
      {
        id: person.id,
        entity: { 'start_date' => new_start_date },
        reference: { 'url' => url, 'name' => 'new reference' }
      }
    end

    let(:patch_request) { proc { patch "/entities/#{person.to_param}", params: params } }

    def self.renders_the_edit_page
      it 'renders the "edit" page' do
        patch_request.call
        expect(response).to have_http_status 200
        expect(response).to render_template(:edit)
      end
    end

    def self.does_not_change_start_date
      it 'does not change the person\'s start date' do
        expect { patch_request.call }.not_to change { Entity.find(person.id).start_date }
      end
    end

    def self.does_not_create_new_reference
      it 'does not create a new reference' do
        expect { patch_request.call }.not_to change { Reference.count }
      end
    end

    context 'Adding a birthday with a new reference' do
      it 'changes start date' do
        patch_request.call
        expect(Entity.find(person.id).start_date).to eql '1900-01-01'
      end

      it 'creates a new reference' do
        expect { patch_request.call }.to change { Reference.count }.by(1)
      end

      it 'redirects to the entity profile page' do
        patch_request.call
        expect(response).to have_http_status 302
        expect(response.location).to include person.to_param
      end
    end

    context "updating an entity's blurb" do
      let(:blurb) { Faker::Lorem.sentence }
      let(:params) do
        { entity: { 'blurb' => blurb }, reference: { just_cleaning_up: 1 } }
      end
      let(:patch_request) { proc { patch "/entities/#{person.id}", params: params } }

      before { person }

      it 'updates blurb and returns 302' do
        expect(&patch_request)
          .to change { Entity.find(person.id).blurb }
                .from(nil).to(blurb)

        expect(response).to have_http_status 302
      end
    end

    context 'submitting a request with an empty blurb' do
      with_versioning do
        let(:params) { { entity: { 'blurb' => '' }, reference: { just_cleaning_up: 1 } } }
        let(:patch_request) { proc { patch "/entities/#{person.id}", params: params } }
        before { person }

        it 'should not create a new paper_trail' do
          expect(&patch_request).not_to change { PaperTrail::Version.count }
        end
      end
    end

    context 'as a restricted user' do
      let(:user) { create_restricted_user }
      context 'redirection' do
        before { patch_request.call }
        redirects_to_dashboard
      end
      does_not_change_start_date
    end

    context 'when submitting an invalid date' do
      let(:new_start_date) { "not a date" }
      does_not_change_start_date
      does_not_create_new_reference
      renders_the_edit_page
    end

    context 'when the reference contains an invalid url' do
      let(:url) { 'i am an invalid url' }
      does_not_change_start_date
      does_not_create_new_reference
      renders_the_edit_page
    end
  end

  describe 'deleting an entity' do
    with_versioning do
      let(:delete_request) { proc { delete "/entities/#{@entity.id}" } }

      context 'user has permission to delete the entity' do
        before do
          PaperTrail.request(whodunnit: user.id.to_s) do
            @entity = create(:entity_org)
          end
        end

        it 'deletes the entity and redirects to dashboard' do
          expect(&delete_request)
            .to change { Entity.unscoped.find(@entity.id).is_deleted }
                  .from(false).to(true)

          redirects_to_path '/home/dashboard'
        end
      end

      context 'user does NOT have permission to delete the entity' do
        context 'entity created by someone else' do
          before do
            PaperTrail.request(whodunnit: (user.id + 1).to_s) do
              @entity = create(:entity_org)
            end
            delete_request.call
          end
          denies_access
        end

        context 'entity created one year ago' do
          before do
            PaperTrail.request(whodunnit: user.id.to_s) do
              @entity = create(:entity_org)
            end
            @entity.update_column(:created_at, 1.year.ago)
            delete_request.call
          end
          denies_access
        end
      end
    end
  end # deleting an enetity

  describe 'adding an image with a url' do
    let(:example_url) { 'https://example.com/image.png' }
    let(:featured) { '0' }
    let(:params) do
      { 'image' => { 'url' => example_url,
                     'title' => 'example image',
                     'is_free' => '1',
                     'is_featured' =>  featured } }
    end

    let(:request) do
      -> { post upload_image_entity_path(person), params: params }
    end

    before do
      expect(Image).to receive(:new_from_url)
                         .with(example_url)
                         .and_return(Image.new(filename: Image.random_filename,
                                               url: example_url,
                                               width: 100,
                                               height: 100))
    end

    it 'creates a new image' do
      expect(&request).to change { Image.count }.by(1)
    end
  end

  it 'redirects /edits to /history' do
    get "/person/#{person.to_param}/edits"
    expect(response).to redirect_to concretize_history_entity_path(person)
  end
end
