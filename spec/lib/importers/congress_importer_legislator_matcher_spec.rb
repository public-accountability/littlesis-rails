require 'importers'

describe CongressImporter::LegislatorMatcher do
  let(:person) do
    create(:entity_person, name: 'William Vollie Alexander Jr.')
  end

  let(:legislator) do
    CongressImporter::Legislator.new(
      { 'id' => { 'bioguide' => 'A000103',
                  'thomas' => '00010',
                  'govtrack' => 400_761,
                  'icpsr' => 12_000,
                  'wikipedia' => 'William Vollie Alexander Jr.',
                  'house_history' => 8_401,
                  'wikidata' => 'Q861905',
                  'google_entity_id' => 'kg:/m/08j19v' },
        'name' => { 'first' => 'William',
                    'middle' => 'Vollie',
                    'last' => 'Alexander',
                    'suffix' => 'Jr.',
                    'nickname' => 'Bill' },
        'bio' => { 'birthday' => '1934-01-16',
                   'gender' => 'M' },
        'terms' => [{ 'type' => 'rep',
                      'start' => '1969-01-03',
                      'end' => '1971-01-03',
                      'state' => 'AR',
                      'district' => 1,
                      'party' => 'Democrat' }] }
    )
  end

  let(:name_hash) do
    { 'name_first' => 'William',
      'name_middle' => 'Vollie',
      'name_last' => 'Alexander',
      'name_suffix' => 'Jr.' }
  end

  it 'finds match with bioguide id' do
    person.create_elected_representative!(bioguide_id: 'A000103')

    # binding.pry
    expect(CongressImporter::LegislatorMatcher.new(legislator).entity)
      .to eq person

  end

  it 'finds match with govtrak id' do
    person.create_elected_representative!(govtrack_id: 400_761)

    expect(CongressImporter::LegislatorMatcher.new(legislator).entity)
      .to eq person
  end

  it 'finds match by name' do
    create(:entity_person).create_elected_representative!(bioguide_id: 'OTHER_BIOGUIDE_ID')

    expect(EntityMatcher).to receive(:find_matches_for_person).once
                               .with(name_hash, { associated: [NotableEntities.fetch(:house_of_reps)] })
                               .and_return(double(automatch: double(entity: build(:person))))

    expect(CongressImporter::LegislatorMatcher.new(legislator).entity).to be_a Entity
  end

  it 'entity is nil if no match is found' do
    expect(EntityMatcher).to receive(:find_matches_for_person).and_return(double(automatch: nil))
    expect(CongressImporter::LegislatorMatcher.new(legislator).entity).to be_nil
  end

end
