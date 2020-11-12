describe Person do
  it { should belong_to(:entity).optional }
  it { should have_db_column(:nationality) }

  it 'has SHORT_FIRST_NAMES constant' do
    expect(Person::SHORT_FIRST_NAMES).to be_a Hash
  end

  it 'has LONG_FIRST_NAMES constant' do
    expect(Person::LONG_FIRST_NAMES).to be_a Hash
  end

  it 'has DISPLAY_ATTRIBUTES' do
    expect(Person::DISPLAY_ATTRIBUTES).to be_a Hash
  end

  describe 'nationality' do
    it 'serializes nationality' do
      person_entity = create(:entity_person)
      expect(person_entity.person.nationality).to eql []
      person_entity.person.nationality.push 'Malagasy'
      expect(person_entity.person.nationality).to eql ['Malagasy']
      person_entity.person.nationality.push 'Laotian'
      expect(person_entity.person.nationality).to eql %w[Malagasy Laotian]
    end

    describe 'add nationality' do
      let(:person) { create(:entity_person).person }

      it 'add nationality to list' do
        expect(person.nationality).to eql []
        person.add_nationality('Canadian')
        expect(person.nationality).to eql ['Canadian']
      end

      it 'does not add duplicates' do
        expect(person.nationality).to eql []
        person.add_nationality('Canadian')
        expect(person.nationality).to eql ['Canadian']
        person.add_nationality('canadian')
        expect(person.nationality).to eql ['Canadian']
      end
    end
  end

  describe 'validations' do
    it { should validate_presence_of(:name_last) }
    it { should validate_presence_of(:name_first) }
    it { should validate_length_of(:name_last).is_at_most(50) }
    it { should validate_length_of(:name_last).is_at_most(50) }
  end

  describe 'titleize_names' do
    let(:the_reverend) { build(:a_person,
                               name_first: 'first',
                               name_last: 'last',
                               name_middle: 'middle',
                               name_suffix: 'II',
                               name_prefix: 'rev.',
                               name_nick: 'the rev') }

    it 'titleizes first and last names' do
      rev = the_reverend
      rev.titleize_names
      expect(rev.name_first).to eq 'First'
      expect(rev.name_last).to eq 'Last'
    end

    it 'titleizes middle and nick name' do
      rev = the_reverend
      rev.titleize_names
      expect(rev.name_middle).to eq 'Middle'
      expect(rev.name_nick).to eq 'The rev'
    end
  end

  describe '#gender' do
    it 'returns correct gender for female, male, & other' do
      expect(build(:a_person, gender_id: 1).gender).to eq 'Female'
      expect(build(:a_person, gender_id: 2).gender).to eq 'Male'
      expect(build(:a_person, gender_id: 3).gender).to eq 'Other'
      expect(build(:a_person, gender_id: nil).gender).to be nil
    end
  end

  describe 'same_first_names' do
    it 'returns list of similar names for abe' do
      names = Person.same_first_names 'abe'
      expect(names).to be_a Array
      expect(names).to include 'abel'
      expect(names).to include 'abraham'
      expect(names).to include 'abram'
    end

    it 'returns list of similar names for cy' do
      names = Person.same_first_names 'cy'
      expect(names).to eq ['cyrus']
    end

    it 'returns empty list if no names found ' do
      names = Person.same_first_names 'mynamecannotbeshorten'
      expect(names).to eq []
    end
  end

  describe 'name_variations' do
    specify do
      p = Person.new(name_first: 'Foo', name_last: 'Bar', name_prefix: "Ms.")
      expect(p.name_variations).to eq ["Foo Bar", "Ms. Foo Bar"]
    end
  end

  describe 'gender_to_id' do
    specify { expect(Person.gender_to_id('F')).to eql 1 }
    specify { expect(Person.gender_to_id(1)).to eql 1 }
    specify { expect(Person.gender_to_id('2')).to eql 2 }
    specify { expect(Person.gender_to_id('male')).to eql 2 }
    specify { expect(Person.gender_to_id('o')).to eql 3 }
    specify { expect(Person.gender_to_id('xyz')).to be nil }
    specify { expect(Person.gender_to_id(nil)).to be nil }
  end
end
