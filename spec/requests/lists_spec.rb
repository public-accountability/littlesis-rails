# rubocop:disable RSpec/ImplicitSubject, RSpec/ImplicitBlockExpectation

describe 'List Requests' do
  let(:user) { create_really_basic_user }
  let(:list) { create(:list, creator_user_id: user.id) }
  let(:entity) { EntitySpecHelpers.org_updated_one_year_ago }

  before { login_as(user, :scope => :user) }

  after { logout(:user) }

  describe 'creating new lists' do
    let(:list_params) do
      {
        'name' => 'example list',
        'short_description' => '',
        'description' => '',
        'access' => '0',
        'is_ranked' => '0',
        'is_admin' => '0',
        'is_featured' => '0'
      }
    end

    context 'without a source url' do
      let(:params) do
        {
          'list' => list_params,
          'ref' => { 'url' => '', 'name' => '' }
        }
      end

      specify do
        expect { post '/lists', params: params }
          .to change(List, :count).by(1)

        expect(response).to have_http_status(302)
      end
    end

    context 'with a source url' do
      let(:params) do
        {
          'list' => list_params,
          'ref' => { 'url' => 'https://example.com', 'name' => '' }
        }
      end

      specify do
        expect { post '/lists', params: params }
          .to change(List, :count).by(1)

        expect(response).to have_http_status(302)
      end
    end

    context 'without a source name' do
      let(:url) { Faker::Internet.url }

      let(:params) do
        {
          'list' => list_params,
          'ref' => { 'url' => url, 'name' => '' }
        }
      end

      specify do
        expect { post '/lists', params: params }.to change(List, :count).by(1)
        expect(response).to have_http_status(302)
        expect(assigns(:list).references.first.document.url).to eq url
      end
    end
  end

  describe 'adding one entity to a list' do
    subject do
      -> { post list_list_entities_path(list), params: { :entity_id => entity.id } }
    end

    it do
      is_expected.to change(ListEntity, :count).by(1)
    end

    it do
      is_expected.to change { entity.reload.last_user_id }.to(user.id)
    end

    it do
      is_expected.to change { entity.reload.updated_at.strftime('%F') }
                       .from(1.year.ago.strftime('%F'))
                       .to(Time.current.strftime('%F'))
    end
  end

  describe 'removing entity from a list' do
    subject do
      -> { delete list_list_entity_path(list, list_entity) }
    end

    let(:list_entity) do
      ListEntity.create!(list_id: list.id, entity_id: entity.id)
    end

    before { list_entity }

    it do
      is_expected.to change(ListEntity, :count).by(-1)
    end

    it do
      is_expected.to change { entity.reload.last_user_id }.to(user.id)
    end
  end

  describe 'adding entities to a list in bulk' do
    let(:user) { create_admin_user } # who may edit lists
    let(:list) { create(:list) }
    let(:entities) { Array.new(2) { create(:random_entity) } }
    let(:document_attrs) { attributes_for(:document) }

    let(:request) do
      lambda { post "/lists/#{list.id}/entities/bulk", params: payload }
    end

    let(:payload) do
      {
        data: [
          { type: 'entities',   id: entities.first.id },
          { type: 'entities',   id: entities.second.id },
          { type: 'references', attributes: document_attrs }
        ]
      }
    end

    context 'with a valid payload' do

      it 'adds entities to the list' do
        expect { request.call }.to change { list.entities.count }.by(2)
      end

      it 'adds a reference to the list' do
        expect { request.call }.to change { list.references.count }.by(1)
      end

      it 'returns 200 with new list entities and new reference' do
        request.call
        expect(response).to have_http_status 200
        expect(json).to eql Api
                              .as_api_json(list.list_entities)
                              .merge('included' => Array.wrap(Reference.last.api_data))
      end
    end

    context 'with improperly formatted json' do
      let(:payload) { { foo: 'bar' } }

      it 'returns 400 with an error message' do
        request.call
        expect(response).to have_http_status 400
        expect(json).to eql Lists::EntityAssociationsController::ERRORS[:entity_associations_bad_format]
      end
    end

    context 'with invalid reference url' do
      let(:payload) do
        {
          data: [
            { type: 'entities',   id: entities.first.id },
            { type: 'entities',   id: entities.second.id },
            { type: 'references', attributes: { name: 'cool', url: 'not cool' } }
          ]
        }
      end

      it 'returns 400 with an error message' do
        request.call
        expect(response).to have_http_status 400
        expect(json).to eql Lists::EntityAssociationsController::ERRORS[:entity_associations_invalid_reference]
      end
    end
  end

  describe 'search', :sphinx do
    before(:all) do # rubocop:disable RSpec/BeforeAfterAll
      setup_sphinx do
        create(:list, name: 'my interesting list').tap do |l|
          ListEntity.create(list_id: l.id, entity_id: create(:entity_person, name: 'Angela Merkel').id)
        end

        create(:list, name: 'some other list')
      end
    end

    after(:all) do # rubocop:disable RSpec/BeforeAfterAll
      teardown_sphinx { delete_entity_tables }
    end

    describe 'finding lists by name' do
      describe 'HTML query' do
        before { get lists_path, params: { q: 'interesting' } }

        it 'returns the correct matching list' do
          expect(response).to have_http_status 200
          expect(assigns[:lists].select { |list| list.name.include? 'interesting' }).not_to be_empty
          expect(assigns[:lists].select { |list| list.name.include? 'other' }).to be_empty
        end
      end

      describe 'JSON query' do
        before { get lists_path, params: { q: 'interesting', format: 'json' } }

        it 'returns the correct matching list' do
          expect(response).to have_http_status 200
          expect(json['results'].select { |list| list['name'].include? 'interesting' }).not_to be_empty
          expect(json['results'].select { |list| list['name'].include? 'other' }).to be_empty
        end

        it 'formats the list in a way that select2 can use' do
          expect(json['results'].first['text']).to eq json['results'].first['name']
        end
      end
    end

    describe 'finding lists that include a given entity' do
      # Can't use a normal let earlier on because this entity needs to be created in the before block
      # for the Sphinx setup.
      let(:entity) { Entity.find_by(name: 'Angela Merkel') }

      describe 'JSON query' do
        before { get lists_path, params: { entity_id: entity.id, format: 'json' } }

        it 'returns the correct matching list' do
          expect(response).to have_http_status 200
          expect(json['results'].select { |list| list['name'].include? 'interesting' }).not_to be_empty
          expect(json['results'].select { |list| list['name'].include? 'other' }).to be_empty
        end
      end
    end
  end
end

# rubocop:enable RSpec/ImplicitSubject, RSpec/ImplicitBlockExpectation
