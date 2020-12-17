describe 'references requests', type: :request do
  let(:user) { create_basic_user }

  before { login_as(user, scope: :user) }

  after { logout(:user) }

  describe 'retriving recent references for a set of entities' do
    let(:entities) { Array.new(2) { create(:entity_org) } }
    let(:non_requested_entity) { create(:entity_person) }

    before do
      (entities + Array.wrap(non_requested_entity)).each do |e|
        e.add_reference(attributes_for(:document))
      end
      get '/references/recent', params: { 'entity_ids' => entities.map(&:id).join(',') }
    end

    it 'returns the references for the entity' do
      expect(response).to have_http_status :ok
      json = JSON.parse(response.body)

      expect(json.length).to eq 2

      expect(json.map { |d| d['id'] }.to_set)
        .to eq (entities.map { |e| e.documents.map(&:id) }.flatten).to_set
    end
  end

  describe 'creating a new reference' do
    let(:entity) do
      create(:entity_person).tap { |e| e.update_column(:updated_at, 1.day.ago) }
    end

    let(:url) { Faker::Internet.url }
    let(:post_data) do
      {
        'data' => {
          'referenceable_id' => entity.id,
          'referenceable_type' => 'Entity',
          'url' => url,
          'name' => 'This is a document',
          'publication_date' => '',
          'ref_type' => '1',
          'excerpt' => nil
        }
      }
    end

    let(:create_new_reference) { -> { post '/references', params: post_data, as: :json } }

    it 'returns "created"' do
      create_new_reference.call
      expect(response).to have_http_status :created
    end

    it 'updates the entity updated_at time' do
      expect(&create_new_reference).to change { entity.reload.updated_at }
    end
  end
end
