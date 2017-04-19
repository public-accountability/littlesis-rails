require 'rails_helper'

describe ReferencesController, type: :controller do
  before(:all) { Entity.skip_callback(:create, :after, :create_primary_ext) }
  after(:all) { Entity.set_callback(:create, :after, :create_primary_ext) }
  before(:each) { DatabaseCleaner.start }
  after(:each) { DatabaseCleaner.clean }

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
    before(:all) do
      @post_data = { data: {
                       object_id: 666,
                       source: 'interesting.net',
                       name: 'a website',
                       object_model: "Relationship",
                       excerpt: "so and so said blah blah blah",
                       ref_type: 1 } }
    end

    before do
      allow(Relationship).to receive(:find) { double('relationship').as_null_object }
    end

    it 'creates a new reference' do
      expect { post(:create, @post_data) }.to change(Reference, :count).by(1)
      expect(Reference.last.object_model).to eql "Relationship"
      expect(Reference.last.source).to eql "interesting.net"
      expect(Reference.last.name).to eql "a website"
      expect(Reference.last.object_id).to eql 666
      expect(Reference.last.last_user_id). to eql SfGuardUser.last.id
      expect(response).to have_http_status(:created)
    end

    it 'creates a new ReferenceExcerpt if there is an excerpt' do
      expect { post(:create, @post_data) }.to change(ReferenceExcerpt, :count).by(1)
      expect(ReferenceExcerpt.last.reference).to eql Reference.last
      expect(Reference.last.excerpt).to eql "so and so said blah blah blah"
    end

    it 'does not create new ReferenceExcept if there is a blank excerpt' do
      expect {
        post(:create, {data: {object_id: 666,
                              source: 'interesting.net',
                              name: 'a website',
                              object_model: "Relationship",
                              excerpt: "",
                              ref_type: 1 }}) 
      }.to change(ReferenceExcerpt, :count).by(0)
      expect(Reference.last.excerpt).to be_nil
    end

    it 'does not create new ReferenceExcept if excerpt is not sent' do 
      expect {
        post(:create, {data: {object_id: 666,
                              source: 'interesting.net',
                              name: 'a website',
                              object_model: "Relationship",
                              ref_type: 1 }})
      }.to change(ReferenceExcerpt, :count).by(0)

      expect(Reference.last.excerpt).to be_nil
    end

    it 'updates updated_at field of the relationship' do
      rel = double("relationship")
      expect(Relationship).to receive(:find).with(666).and_return(rel)
      expect(rel).to receive(:touch)
      post(:create, @post_data)
    end

    it 'returns json of errors if reference is not valid' do
      post(:create, {data: {
                       object_id: 666,
                       object_model: "Relationship",
                       ref_type: 1}
                    })
      body = JSON.parse(response.body)

      expect(response).to have_http_status(400)
      expect(body['errors']['source']).to eql ["can't be blank"]
    end
  end

  describe 'DELETE /reference' do
    login_user

    before(:all) do
      @ref = create(:ref, source: 'link', object_id: 1234)
    end

    it 'deletes a reference' do
      expect { delete :destroy, id: @ref }.to change(Reference, :count).by(-1)
      expect(response).to have_http_status(200)
    end

    it 'bad_requests for bad ids' do
      delete :destroy, id: 8888
      expect(response).to have_http_status(400)
    end
  end

  describe '/recent' do
    login_user

    before(:all) do
      @e1 = create(:person)
      @e2 = create(:person)
    end

    def sample_get
      expect(Reference).to receive(:last).with(2).and_return(['last']).once
      expect(Reference).to receive(:recent_references).and_return(['recent'])
      get(:recent, entity_ids: [@e1.id, @e2.id])
    end

    it 'has status 200' do
      sample_get
      expect(response).to have_http_status(200)
    end

    it 'has correct json' do
      sample_get
      expect(response.body).to eq ["last", "recent"].to_json
    end

    it 'send correct information to recent references' do
      expect(Reference).to receive(:last).with(2).and_return(['last'])
      input = [{ :class_name => 'Entity', :object_ids => [@e1.id, @e2.id] }]
      expect(Reference).to receive(:recent_references).with(input, 20).and_return(['recent'])
      get(:recent, entity_ids: [@e1.id, @e2.id])
      expect(response.body).to eq ["last", "recent"].to_json
    end

    it 'send correct information to recent references if there is a relationship' do
      r = Relationship.create!(entity1_id: @e1.id, entity2_id: @e2.id, category_id: 12)
      expect(Reference).to receive(:last).with(2).and_return(['last'])
      input = [
        { class_name: 'Entity', object_ids: [@e1.id, @e2.id] },
        { class_name: 'Relationship', object_ids: [r.id] }
      ]
      expect(Reference).to receive(:recent_references).with(input, 20).and_return(['recent'])
      get(:recent, entity_ids: [@e1.id, @e2.id])
      expect(response.body).to eq ["last", "recent"].to_json
    end
  end

  describe 'entity' do
    it 'returns bad request if missing entity_id' do
      get :entity
      expect(response).to have_http_status 400
    end

    it 'calls recent_source_links with correct entity_id and default values' do
      entity = build(:org, id: 123)
      expect(Entity).to receive(:find).with('123').and_return(entity)
      expect(Rails.cache).to receive(:fetch).once.and_call_original
      expect(Reference).to receive(:recent_source_links).with(entity, 1, 10).and_return([])
      get :entity, { 'entity_id' => '123' }
    end

    it 'calls recent_source_links with correct entity_id and page' do
      entity = build(:org, id: 123)
      expect(Entity).to receive(:find).with('123').and_return(entity)
      expect(Rails.cache).to receive(:fetch).once.and_call_original
      expect(Reference).to receive(:recent_source_links).with(entity, 3, 10).and_return([])
      get :entity, { 'entity_id' => '123', 'page' => 3 }
    end
  end
end
