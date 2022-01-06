describe 'Entity Requests', type: :request do
  include EntitiesHelper

  let(:person) { create(:entity_person, start_date: '2000-01-01', blurb: nil) }
  let(:user) { create_basic_user }

  before { login_as(user, :scope => :user) }
  after { logout(:user) }

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
      expect(&new_entity_request).to change(Entity, :count).by(1)
    end

    it 'sets blurb to nil if blank' do
      new_entity_request.call
      entity = Entity.last
      expect(entity.name).to eq 'John Henry'
      expect(entity.blurb).to eq nil
    end

    it 'redirects to edit url page' do
      post '/entities', params: { "entity" => { "name" => "new entity", "blurb" => "a blurb goes here", "primary_ext" => "Org" } }
      expect(response).to have_http_status :found
      expect(response.location).to include concretize_edit_entity_path(Entity.last)
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
          expect(&patch_request).not_to change { ApplicationVersion.count }
        end
      end
    end

    describe "Updating Orgs" do
      let(:org) { create(:entity_org) }

      let(:patch_request) do
        -> { patch "/entities/#{org.to_param}", params: params }
      end

      describe 'Updating an Org without a reference' do
        let(:params) do
          { id: org.id, entity: { 'website' => 'http://example.com' }, reference: { 'just_cleaning_up' => '1' } }
        end

        it 'updates entity field' do
          expect(&patch_request).to change { org.reload.website }.from(nil).to('http://example.com')
        end

        it 'does not create a new reference' do
          expect(&patch_request).not_to change(Reference, :count)
        end

        it 'updates last_user_id' do
          expect(&patch_request).to change { org.reload.last_user_id }.to(user.id)
        end
      end

      describe 'Updating an Org with a reference' do
        let(:params) do
          { id: org.id,
            entity: { 'start_date' => '1929-08-08' },
            reference: { 'url' => 'http://example.com', 'name' => 'new reference' } }
        end

        it 'updates entity field' do
          expect(&patch_request).to change { org.reload.start_date }.from(nil).to('1929-08-08')
        end

        it 'creates a new reference' do
          expect(&patch_request).to change(Reference, :count).by(1)
        end

        it 'redirects to legacy url' do
          patch_request.call
          expect(response).to redirect_to concretize_entity_path(org)
        end
      end
    end

    describe 'Adding and removing types' do
      let!(:org) { create(:entity_org) }

      let(:extension_def_ids) { '' }

      let(:params) do
        { id: org.id,
          entity: { 'extension_def_ids' => extension_def_ids },
          reference: { 'url' => 'http://example.com', 'name' => 'new reference' } }
      end

      let(:patch_request) do
        -> { patch "/entities/#{org.to_param}", params: params }
      end

      describe 'adding new types' do
        let(:extension_def_ids) { '8,9,10' }

        it 'is_expected.to create 3 new extension records' do
          expect(&patch_request).to change(ExtensionRecord, :count).by(3)
        end

        it 'redirects to legacy url' do
          patch_request.call
          expect(response).to redirect_to concretize_entity_path(org)
        end
      end

      describe 'removing types' do
        before { org.add_extension('School') }

        it 'is_expected.to remove one extension records' do
          expect(&patch_request).to change(ExtensionRecord, :count).by(-1)
        end

        it 'is_expected.to remove School model' do
          expect(&patch_request).to change(School, :count).by(-1)
        end

        it 'redirects to legacy url' do
          patch_request.call
          expect(response).to redirect_to concretize_entity_path(org)
        end
      end
    end

    describe 'updating a person with a first name that is too long' do
      let(:person) { create(:entity_person) }

      let(:params) do
        { id: person.id,
          entity: { 'blurb' => 'new blurb',
                    'person_attributes' => { 'name_first' => "#{'x' * 51}",
                                             'id' => person.person.id } },
          reference: { 'reference_id' => '123' } }
      end

      it 'does not change the first name' do
        expect { patch("/entities/#{person.to_param}", params: params) }.not_to change { person.reload.person.name_first }
      end
    end

    describe 'updating a public company' do
      let(:public_company) { create(:public_company_entity) }
      let(:params) do
        { id: public_company.id,
          entity: {
            name: public_company.name,
            public_company_attributes: {
              id: public_company.public_company.id,
              ticker: 'ABC'
            },
            business_attributes: {
              id: public_company.business.id,
              annual_profit: 999,
              assets: 100,
              marketcap: 200,
              net_income: 300
            }
          },
          reference: { 'url' => 'http://example.com', 'name' => 'new reference' } }
      end

      it 'updates ticker' do
        expect(Entity.find(public_company.id).public_company.ticker).to eq 'XYZ'
        expect { patch "/entities/#{public_company.to_param}", params: params }.to change { public_company.reload.public_company.ticker }.to('ABC')
      end

      it 'updates business fields' do
        patch "/entities/#{public_company.to_param}", params: params
        expect(public_company.business.reload).to have_attributes(annual_profit: 999, assets: 100, marketcap: 200, net_income: 300)
      end

      it 'redirects to entity url' do
        patch "/entities/#{public_company.to_param}", params: params
        expect(response).to redirect_to concretize_entity_path(public_company)
      end
    end

    describe 'validate' do
      it 'returns validation errors for invalid entities' do
        post entities_validate_path, params: { entity: { name: 'Mr Aesop', blurb: 'Hic Rhodus hic salta', primary_ext: '' } }

        expect(response.status).to eq 200

        body = JSON.parse(response.body)
        expect(body["name"].first).to eq("Could not find a first name. Mr is a common prefix")
        expect(body["primary_ext"].first).to eq("can't be blank")
      end

      it 'returns nothing for valid entities' do
        post entities_validate_path, params: { entity: { name: 'Carl Schmitt', blurb: 'The exception proves everything.', primary_ext: 'org' } }
        expect(response.status).to eq 200
        expect(JSON.parse(response.body)).to eq({})
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
      -> { post concretize_entity_images_path(person), params: params }
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
      expect(&request).to change(Image, :count).by(1)
    end
  end

  it 'redirects /edits to /history' do
    get "/person/#{person.to_param}/edits"
    expect(response).to redirect_to concretize_history_entity_path(person)
  end

  describe 'from the /entities/id/add_relationship page' do
    let(:params) { { "entity" => { "name" => "new entity", "blurb" => "a blurb goes here", "primary_ext" => "Org" } } }
    let(:params_missing_ext) { { "entity" => { "name" => "new entity", "blurb" => "a blurb goes here", "primary_ext" => "" } } }
    let(:params_add_relationship_page) { params.merge({ 'add_relationship_page' => 'TRUE' }) }
    let(:params_missing_ext_add_relationship_page) { params_missing_ext.merge({ 'add_relationship_page' => 'TRUE' }) }

    context 'without errors' do
      it 'is_expected.to create a new entity' do
        expect { post '/entities', params: params_add_relationship_page }.to change(Entity, :count).by(1)
      end

      it 'is_expected.to render json with entity id' do
        post '/entities', params: params_add_relationship_page
        json = JSON.parse(response.body)
        expect(json.fetch('status')).to eql 'OK'
        expect(json['entity']['id']).to eql Entity.last.id
        expect(json['entity']).to have_key 'name'
        expect(json['entity']).to have_key 'url'
        expect(json['entity']).to have_key 'description'
        expect(json['entity']).to have_key 'primary_ext'
      end
    end

    context 'with errors' do
      it 'is_expected.to NOT create a new entity' do
        expect { post '/entities', params: params_missing_ext_add_relationship_page }
          .not_to change(Entity, :count)
      end

      it 'is_expected.to render json with errors' do
        post '/entities', params: params_missing_ext_add_relationship_page
        expect(JSON.parse(response.body)).to have_key 'errors'
        expect(JSON.parse(response.body).fetch('status')).to eql 'ERROR'
      end
    end
  end
end
