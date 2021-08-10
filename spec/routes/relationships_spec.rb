describe 'relationship routes', type: :routing do
  let(:relationship) { create(:generic_relationship, entity: create(:entity_person), related: create(:entity_person)) }

  it 'routes old-style relationship URLs' do
    expect(get: "/relationship/view/id/#{relationship.id}").to route_to(
      controller: 'relationships/routes',
      action: 'redirect_to_canonical',
      id: relationship.id.to_s
    )
  end
end
