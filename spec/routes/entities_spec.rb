describe 'entities routes', type: :routing do
  let(:person) { create(:entity_person, name: 'Tronald Dump') }
  let(:org) { create(:entity_org, name: 'Malwart') }

  it 'routes /entities/ paths to the relevant entities' do
    expect(get: "/entities/#{person.id}-Tronald_Dump").to route_to(
      controller: 'entities',
      action: 'show',
      id: "#{person.id}-Tronald_Dump"
    )
  end

  it 'routes /person/ paths to the relevant entities' do
    expect(get: "/person/#{person.id}-Tronald_Dump").to route_to(
      controller: 'entities',
      action: 'show',
      id: "#{person.id}-Tronald_Dump"
    )
  end

  it 'routes /org/ paths to the relevant entities' do
    expect(get: "/org/#{org.id}-Malwart").to route_to(
      controller: 'entities',
      action: 'show',
      id: "#{org.id}-Malwart"
    )
  end
end
