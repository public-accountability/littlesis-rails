require 'rails_helper'

describe 'List Requests' do
  let(:user) { create_really_basic_user }
  before(:each) { login_as(user, :scope => :user) }
  after(:each) { logout(:user) }

  describe 'adding entities to a list' do
    let(:user){ create_admin_user } # who may edit lists
    let(:list) { create(:list) }
    let(:entities) { Array.new(2) { create(:random_entity) } }
    let(:document_attrs) { attributes_for(:document) }

    let(:request) { lambda { post "/lists/#{list.id}/entities/bulk", payload } }
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
      let(:payload){ { foo: 'bar' } }

      it 'returns 400 with an error message' do
        request.call
        expect(response).to have_http_status 400
        expect(json).to eql ListsController::ERRORS[:entity_associations_bad_format]
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
        expect(json).to eql ListsController::ERRORS[:entity_associations_invalid_reference]
      end
    end
  end
end
