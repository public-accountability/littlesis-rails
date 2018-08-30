require 'rails_helper'

describe 'Datatable' do
  let!(:entity) { create(:entity_person) }
  let!(:relationship) do
    create(:position_relationship, entity: entity, related: create(:entity_org))
  end

  before { get "/datatable/entity/#{entity.id}" }

  it 'returns valid json response' do
    expect(response).to have_http_status 200
    expect(response['Cache-Control']).to include 'public'
    expect(json['relationships'].count).to eql 1
  end
end
