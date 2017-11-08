require 'rails_helper'

describe 'Entity Requests', type: :request do
  let(:person) { create(:entity_person, start_date: '2000-01-01') }
  let(:user) { create_really_basic_user }

  before(:each) { login_as(user, :scope => :user) }
  after(:each) { logout(:user) }

  describe 'creating many entities' do

    let(:payload) { { entities: Array.new(3) { build(:random_entity) }.map(&:attributes) } }
    let(:request) { lambda { post '/entities/create_many.json', payload } }

    context 'with valid payload' do
      it 'returns 201 with a collection of entities with new ids appended' do
        expect { request.call }.to change { Entity.count }.by(3)
        expect(response).to have_http_status 201
        expect(json).to eql(Api.as_api_json(Entity.last(3)))
      end
    end

    context 'with invalid payload' do
      let(:payload) { { entities: [{ is_admin: true }] } }

      it 'returns 400 with an error message' do
        expect { request.call }.to change { Entity.count }.by(0)
        expect(response).to have_http_status 400
        expect(json)
          .to eql('errors' => [{ 'title' => 'Could not create new entities: request formatted improperly' }])
      end
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

    let(:patch_request) { proc { patch "/entities/#{person.to_param}", params } }

    def renders_the_edit_page
      patch_request.call
      expect(response).to have_http_status 200
      expect(response).to render_template(:edit)
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

    context 'when submitting an invalid date' do
      let(:new_start_date) { "not a date" }

      it 'does not change the person\'s start date' do
        expect { patch_request.call }.not_to change { Entity.find(person.id).start_date }
      end

      it 'does not create a new reference' do
        expect { patch_request.call }.not_to change { Reference.count }
      end

      it 'renders the "edit" page' do
        renders_the_edit_page
      end
    end

    context 'when the reference contains an invalid url' do
      let(:url) { 'i am an invalid url' }
     
      it 'does not change the person\'s start date' do
        expect { patch_request.call }.not_to change { Entity.find(person.id).start_date }
      end

      it 'does not create a new reference' do
        expect { patch_request.call }.not_to change { Reference.count }
      end

      it 'renders the "edit" page' do
        renders_the_edit_page
      end
    end
    
  end
end
