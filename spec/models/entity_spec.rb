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
    def create_human
      human = create(:person)
      human.create_primary_ext
      human
    end

    def create_corp
      corp = create(:corp)
      corp.create_primary_ext
      corp
    end

    def create_school
      school = create(:org, name: 'private school')
      school.create_primary_ext
      school.add_extension 'School', is_private: true
      school
    end

    def without_ids(array)
      array.reject { |c| c == 'id' || c == 'entity_id' }
    end

    describe '#extension_attributes' do
      it 'includes person attributes except for id or entity_id' do
        human_extension_attributes = create_human.extension_attributes
        
        without_ids(Person.column_names).each do |col|
          expect(human_extension_attributes.has_key?(col)).to be true
        end
        
        expect(human_extension_attributes.has_key?('id')).to be false
        expect(human_extension_attributes.has_key?('entity_id')).to be false
      end

      it 'includes org attributes except for id or entity_id' do
        corp_extension_attributes = create_corp.extension_attributes
        without_ids(Org.column_names).each do |col|
          expect(corp_extension_attributes.has_key?(col)).to be true
        end
        expect(corp_extension_attributes.has_key?('id')).to be false
        expect(corp_extension_attributes.has_key?('entity_id')).to be false
      end

      it 'includes school attributes if entity is a school' do
        school_extension_attributes =  create_school.extension_attributes
        without_ids(School.column_names).each do |col|
          expect(school_extension_attributes.has_key?(col)).to be true
        end
      end
    end
  end # end Extension Attributes Functions
end
