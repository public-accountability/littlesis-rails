require 'rails_helper'

describe Entity do
  before(:all) do
    DatabaseCleaner.start
    Entity.skip_callback(:create, :after, :create_primary_ext)
  end
  after(:all) do
    Entity.set_callback(:create, :after, :create_primary_ext)
    DatabaseCleaner.clean
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:primary_ext) }
    it 'validates that there are at least two words in a name if the entity is a person' do
      e = Entity.new(primary_ext: 'Person', name: 'my name')
      expect(e.valid?).to be true
    end

    it 'fails validation if Person is mising last name' do
      e = Entity.new(primary_ext: 'Person', name: 'onewordname')
      expect(e.valid?).to be false
    end

    it 'valides orgs with one word names' do
      e = Entity.new(primary_ext: 'Org', name: 'onewordname')
      expect(e.valid?).to be true
    end
  end

  describe 'summary_excerpt' do
    it 'returns nil if there is no summary' do
      mega_corp = build(:mega_corp_inc, summary: nil)
      expect(mega_corp.summary_excerpt).to be_nil
    end

    it 'truncates to under 100 chars' do
      mega_corp = build(:mega_corp_inc, summary: 'word ' * 50)
      expect(mega_corp.summary_excerpt.length).to be < 100
    end

    it 'returns just the first  paragraph even if the paragraph is less than 100 chars' do
      summary = ('x ' * 25) + "\n" + ('word ' * 25)
      mega_corp = build(:mega_corp_inc, summary: summary)
      expect(mega_corp.summary_excerpt.length).to eql(53)
      expect(mega_corp.summary_excerpt).to eql(('x ' * 25) + '...')
    end
  end

  describe 'Political' do
    describe 'sqlize_array' do
      it 'stringifies an array for a sql query' do 
        expect(Entity.sqlize_array ['123', '456', '789']).to eql("('123','456','789')")
      end
    end

    describe '#potential_contributions' do
      describe '#name_query_string' do
        it 'returns correct string if length of names is 1' do
          expect(Entity.name_query_string([{}])).to eql ' (name_first = ? and name_last = ?) '
        end

        it 'returns correct string if length of names is > 1' do
          expect(Entity.name_query_string([{}, {}])).to eql " (name_first = ? and name_last = ?) OR (name_first = ? and name_last = ?) "
          expect(Entity.name_query_string([{}, {}, {}])).to eql " (name_first = ? and name_last = ?) OR (name_first = ? and name_last = ?) OR (name_first = ? and name_last = ?) "
        end
      end
    end
  end # end political

  describe 'Extension Attributes Functions' do
    before(:all) { Entity.set_callback(:create, :after, :create_primary_ext) }
    after(:all) { Entity.skip_callback(:create, :after, :create_primary_ext) }

    def create_school
      school = create(:org, name: 'private school')
      school.add_extension 'School', is_private: true
      school
    end

    def without_ids(array)
      array.reject { |c| c == 'id' || c == 'entity_id' }
    end

    describe '#extension_attributes' do
      it 'includes person attributes except for id or entity_id' do
        human_extension_attributes = create(:person).extension_attributes

        without_ids(Person.column_names).each do |col|
          expect(human_extension_attributes.key?(col)).to be true
        end

        expect(human_extension_attributes.key?('id')).to be false
        expect(human_extension_attributes.key?('entity_id')).to be false
      end

      it 'includes org attributes except for id or entity_id' do
        corp_extension_attributes = create(:corp).extension_attributes
        without_ids(Org.column_names).each do |col|
          expect(corp_extension_attributes.key?(col)).to be true
        end
        expect(corp_extension_attributes.key?('id')).to be false
        expect(corp_extension_attributes.key?('entity_id')).to be false
      end

      it 'includes school attributes if entity is a school' do
        school_extension_attributes = create_school.extension_attributes
        without_ids(School.column_names).each do |col|
          expect(school_extension_attributes.key?(col)).to be true
        end
      end

      it 'works with example Business Person' do
        person = create(:person, name: 'johnny business')
        person.add_extension('BusinessPerson', sec_cik: 987)
        expect(person.extension_attributes).to eql ({
                                                       'sec_cik' => 987,
                                                       'name_first' => 'Johnny',
                                                       'name_last' => 'Business',
                                                       'name_middle' => nil,
                                                       'name_prefix' => nil,
                                                       'name_suffix' => nil,
                                                       'name_nick' => nil,
                                                       'birthplace' => nil,
                                                       'gender_id' => nil,
                                                       'party_id' => nil,
                                                       'is_independent' => nil,
                                                       'net_worth' => nil,
                                                       'name_maiden' => nil,
                                                     })
      end
    end

    describe '#extensions_with_attributes' do
      let(:human) { create(:person) }
      let(:school) { create_school }

      it 'returns hash with key "Person"' do
        expect(human.extensions_with_attributes.key?('Person')).to be true
        expect(human.extensions_with_attributes.keys.length).to eql 1
      end

      it 'Person hash hass person attributes' do
        without_ids(Person.column_names).each do |col|
          expect(human.extension_attributes.key?(col)).to be true
        end

        expect(human.extension_attributes.key?('id')).to be false
        expect(human.extension_attributes.key?('entity_id')).to be false
      end

      it 'School has org and school keys' do
        expect(school.extensions_with_attributes.key?('School')).to be true
        expect(school.extensions_with_attributes.key?('Org')).to be true
        expect(school.extensions_with_attributes.length).to eql 2
      end
    end

    describe '#extension_names' do
      it 'returns ["Org"] if is an org' do
        expect(create(:org).extension_names).to eql ['Org']
      end

      it 'returns ["Person"] if is an person' do
        expect(create(:person).extension_names).to eql ['Person']
      end

      it 'includes school and org if Entity is also a school' do
        expect(create_school.extension_names). to eql ['Org', 'School']
      end
    end
  end # end Extension Attributes Functions
end
