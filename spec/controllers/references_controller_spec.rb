require 'rails_helper'

describe ReferencesController, type: :controller do
  before(:all) { Entity.skip_callback(:create, :after, :create_primary_ext) }
  after(:all) { Entity.set_callback(:create, :after, :create_primary_ext) }

  it { should route(:post, '/references').to(action: :create) }
  it { should route(:delete, '/references/1').to(action: :destroy, id: 1) }
  it { should route(:get, '/references/recent').to(action: :recent) }
  it { should route(:get, '/references/entity').to(action: :entity) }

  describe 'auth' do
    it 'redirects to login if user is not logged in' do
      post(:create)
      expect(response).to have_http_status(302)
    end
  end

  describe 'POST /reference' do
    login_user
    let(:relationship) do
      create(:generic_relationship, entity: create(:entity_person), related: create(:entity_org))
    end
    let(:post_data) do
      { data: {
          referenceable_id: relationship.id,
          url: Faker::Internet.unique.url,
          name: 'a website',
          referenceable_type: "Relationship",
          excerpt: "so and so said blah blah blah",
          ref_type: 1 } }
    end
    let(:post_request) { proc { post(:create, params: post_data) } }

    it 'responds with created' do
      post_request.call
      expect(response).to have_http_status(:created)
    end

    it 'creates a new reference' do
      expect { post_request.call }.to change { Reference.count }.by(1)
    end

    it 'creates a new document' do
      expect { post_request.call }.to change(Document, :count).by(1)
    end

    it 'updates the updated_at and last_user_id field of the relationship' do
      relationship.update_column(:updated_at, 1.year.ago)
      post_request.call
      expect(relationship.reload.updated_at.strftime('%F')).to eq Time.now.strftime('%F')
      expect(relationship.last_user_id).to eql controller.current_user.sf_guard_user_id
    end

    it 'returns json of errors if reference is not valid' do
      post(:create, params: {
                              data: {
                                referenceable_id: relationship.id,
                                referenceable_type: "Relationship",
                                ref_type: 1
                              }
           })

      body = JSON.parse(response.body)
      expect(response).to have_http_status(400)
      expect(body['errors']['url']).to eql ["can't be blank"]
    end

    xit 'returns json of errors if reference name is too long' do
      post(:create, { params: {
                        data: { object_id: 666,
                              source: 'https://example.com',
                              name: 'x' * 101,
                              object_model: "Relationship",
                              ref_type: 1 } }  })

      body = JSON.parse(response.body)

      expect(response).to have_http_status(400)
      expect(body['errors']['name'][0]).to include "is too long"
    end
  end

  describe 'DELETE /reference' do
    login_user
    let(:existing_ref_id) { 1 }
    let(:nonexisting_ref_id) { 2 }

    context 'reference exists' do
      before do
        expect(Reference).to receive(:find).with('123').and_return(double(:destroy! => nil))
        delete :destroy, params: { id: '123' }
      end
      specify { expect(response).to have_http_status(200) }
    end

    context 'reference does not exist' do
      before do
        expect(Reference).to receive(:find).with('123').and_raise(ActiveRecord::RecordNotFound)
        delete :destroy, params: { id: '123' }
      end
      specify { expect(response).to have_http_status(400) }
    end
  end

  describe '/references/recent' do
    login_user

    def get_recent_references(params)
      p = { entity_ids: '1,2,3' }.merge(params)
      get :recent, params: p
    end

    def reference_is_called_with_last
      expect(Reference).to receive(:last).with(2)
                             .and_return(double(:map => [build(:document)]))
    end

    def document_is_called_with(*args)
      expect(Document).to receive(:documents_for_entity)
                            .with(*args)
                            .and_return([build(:document)])
    end

    before(:each) { reference_is_called_with_last }

    it 'uses default values' do
      document_is_called_with(entity: [1, 2, 3], page: 1, per_page: 10, exclude_type: :fec)
      get_recent_references({})
    end

    it 'can change per_page' do
      document_is_called_with(entity: [1, 2, 3], page: 1, per_page: 50, exclude_type: :fec)
      get_recent_references({per_page: '50'})
    end

    it 'can change page' do
      document_is_called_with(entity: [1, 2, 3], page: 2, per_page: 10, exclude_type: :fec)
      get_recent_references({page: '2'})
    end

    it 'can change exclude_type' do
      document_is_called_with(entity: [1, 2, 3], page: 1, per_page: 10, exclude_type: :government)
      get_recent_references({exclude_type: 'government'})
    end

    it 'can change all three' do
      document_is_called_with(entity: [1, 2, 3], page: 2, per_page: 50, exclude_type: :government)
      get_recent_references({exclude_type: 'government', page: '2', per_page: '50'})
    end
  end

  describe 'entity' do
    it 'returns bad request if missing entity_id' do
      get :entity
      expect(response).to have_http_status 400
    end
  end
end
