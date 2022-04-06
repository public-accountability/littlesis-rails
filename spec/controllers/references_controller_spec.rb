describe ReferencesController, type: :controller do
  it { is_expected.to route(:post, '/references').to(action: :create) }
  it { is_expected.to route(:delete, '/references/1').to(action: :destroy, id: 1) }
  it { is_expected.to route(:get, '/references/recent').to(action: :recent) }
  it { is_expected.to route(:get, '/references/entity').to(action: :entity) }

  describe 'auth' do
    it 'redirects to login if user is not logged in' do
      post(:create)
      expect(response).to have_http_status :found
    end
  end

  describe 'POST /reference' do
    login_user
    let(:relationship) do
      create(:generic_relationship, entity: create(:entity_person), related: create(:entity_org))
    end

    let(:post_data) do
      { data: { referenceable_id: relationship.id,
                url: Faker::Internet.unique.url,
                name: 'a website',
                referenceable_type: "Relationship",
                excerpt: "so and so said blah blah blah" } }
    end

    it 'responds with created for forms' do
      post(:create, params: post_data)
      expect(response).to have_http_status :found
    end

    it 'responds with created for json' do
      post(:create, params: post_data, as: :json)
      expect(response).to have_http_status(:created)
    end

    it 'creates a 3 new references' do
      expect { post(:create, params: post_data) }.to change(Reference, :count).by(3)
      expect(relationship.references.count).to eq 1
    end

    it 'creates a new document' do
      expect { post(:create, params: post_data) }.to change(Document, :count).by(1)
    end

    it 'updates the updated_at and last_user_id field of the relationship' do
      relationship.update_column(:updated_at, 1.year.ago)
      post(:create, params: post_data)
      expect(relationship.reload.updated_at.strftime('%F')).to eq Time.current.strftime('%F')
      expect(relationship.last_user_id).to eq User.system_user_id
    end
  end

  describe 'DELETE /reference' do
    login_user :admin
    let(:existing_ref_id) { 1 }
    let(:nonexisting_ref_id) { 2 }

    context 'when reference exists' do
      before do
        expect(Reference).to receive(:find).with('123').and_return(double(:destroy! => nil))
        delete :destroy, params: { id: '123' }
      end

      specify { expect(response).to have_http_status(200) }
    end

    context 'when reference does not exist' do
      before do
        expect(Reference).to receive(:find).with('123').and_raise(ActiveRecord::RecordNotFound)
        delete :destroy, params: { id: '123' }
      end

      specify { expect(response).to have_http_status(:bad_request) }
    end
  end

  describe 'entity' do
    it 'returns bad request if missing entity_id' do
      get :entity
      expect(response).to have_http_status :bad_request
    end
  end
end
