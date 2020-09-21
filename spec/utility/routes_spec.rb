describe Routes, type: :feature do
  let(:org) { build(:org) }
  let(:person) { build(:person) }

  it 'changes path prefix from entities' do
    expect(entity_path(org)).to eql "/org/#{org.to_param}"
    expect(entity_path(person)).to eql "/person/#{person.to_param}"
  end

  it 'changes member routes' do
    expect(interlocks_entity_path(org)).to eql "/org/#{org.to_param}/interlocks"
  end

  it 'does not change post routes' do
    expect(match_donation_entity_path(org)).to eql "/entities/#{org.to_param}/match_donation"
  end

  it 'modifies URL helpers' do
    expect(interlocks_entity_url(org))
      .to eql "http://www.example.com/org/#{org.to_param}/interlocks"
  end

  # NOTE: if an entity route is added or removed this test will fail.
  #       and will need to be updated.
  #
  # The code that generates ROUTES_TO_MODIFY reaches deep into the rails API
  # and thus might change between rails versions
  # This test will hopefully catch that if it does
  it 'modifies 19 routes' do
    expect(Routes::ROUTES_TO_MODIFY.length).to eql 19
  end

  describe 'modify_entity_path' do
    it 'changes entities to "org" or "person" for any string path' do
      expect(Routes.modify_entity_path('http://example.com/entities/123', org))
        .to eql 'http://example.com/org/123'

      expect(Routes.modify_entity_path('http://example.com/entities/123', person))
        .to eql 'http://example.com/person/123'
    end
  end

  describe 'entity_url and entity_path' do
    it 'generates url for an org' do
      expect(Routes.entity_url(org)).to eql "http://test.host/org/#{org.to_param}"
    end

    it 'generates path for a person' do
      expect(Routes.entity_path(person)).to eql "/person/#{person.to_param}"
    end

    it 'generates edit entity path' do
      expect(Routes.edit_entity_path(person)).to eql "/person/#{person.to_param}/edit"
    end
  end
end
