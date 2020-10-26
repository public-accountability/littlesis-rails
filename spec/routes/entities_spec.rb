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

  it 'routes path to history to edits controller' do
    expect(get: "#{org.slug}/history").to route_to(
                                            controller: 'edits',
                                            action: 'entity',
                                            id: org.to_param)
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

  it 'routes old-style person URLs' do
    expect(get: "/person/#{person.id}/arbitrary/string").to route_to(
      controller: 'entities/routes',
      action: 'redirect_to_canonical',
      id: person.id.to_s,
      remainder: 'arbitrary/string'
    )
  end

  it 'routes old-style org URLs' do
    expect(get: "/org/#{org.id}/arbitrary/string").to route_to(
      controller: 'entities/routes',
      action: 'redirect_to_canonical',
      id: org.id.to_s,
      remainder: 'arbitrary/string'
    )
  end

  describe 'redirection of old-style URLs', type: :request do
    it 'redirects to the canonical person URL' do
      expect(get "/person/#{person.id}/arbitrary/string").to redirect_to("/person/#{person.id}-Tronald_Dump")
    end

    it 'redirects to the canonical org URL' do
      expect(get "/person/#{org.id}/arbitrary/string").to redirect_to("/org/#{org.id}-Malwart")
    end

    it 'raises a 404 for unrecognised entities' do
      get '/person/098765432/arbitrary/string'
      expect(response).to have_http_status(:not_found)
    end
  end
end
