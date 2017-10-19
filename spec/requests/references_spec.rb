require 'rails_helper'

describe 'references requests', type: :request do
  let(:user) { create_basic_user }
  before { login_as(user, scope: :user) }
  after(:each) { logout(:user) }

  describe 'retriving recent references for a set of entities' do
    let(:entities) { Array.new(2) { create(:entity_org) } }
    let(:non_requested_entity) { create(:entity_person) }

    before do
      (entities + Array.wrap(non_requested_entity)).each do |e|
        e.add_reference(attributes_for(:document))
      end
      get '/references/recent', 'entity_ids' => "#{entities.map(&:id).join(',')}"
    end

    it 'returns the references for the entity plus the recent reference' do
      expect(response).to have_http_status 200
      json = JSON.parse(response.body)

      expect(json.length).to eql 3

      expect(json.map { |d| d['id'] }.to_set)
        .to eql (entities.map { |e| e.documents.map(&:id) }.flatten + non_requested_entity.documents.map(&:id)).to_set
    end
  end
end
