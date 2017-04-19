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

    describe 'Date Validation' do
      def build_entity(attr)
        build(:org, {id: rand(1000)}.merge(attr) )
      end

      it 'accepts good dates' do
        expect(build_entity(start_date: '2000-00-00').valid?).to be true
        expect(build_entity(end_date: '2000-10-00').valid?).to be true
        expect(build_entity(end_date: '2017-01-20').valid?).to be true
        expect(build_entity(start_date: nil).valid?).to be true
      end

      it 'does not accept bad dates' do
        expect(build_entity(start_date: '2000-13-00').valid?).to be false
        expect(build_entity(end_date: '2000-10').valid?).to be false
        expect(build_entity(end_date: '2017').valid?).to be false
        expect(build_entity(start_date: '').valid?).to be false
      end
    end
  end

  describe 'summary_excerpt' do
    it 'returns nil if there is no summary' do
      mega_corp = build(:mega_corp_inc, summary: nil)
      expect(mega_corp.summary_excerpt).to be_nil
    end

    it 'truncates to under 150 chars' do
      mega_corp = build(:mega_corp_inc, summary: 'word ' * 50)
      expect(mega_corp.summary_excerpt.length).to be < 150
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
    
    describe 'name_or_id_to_name' do
      it 'converts def id to name' do
        expect(Entity.new.send(:name_or_id_to_name, 5)).to eq 'Business'
      end

      it 'returns valid name' do
        expect(Entity.new.send(:name_or_id_to_name, 'LaborUnion')).to eq 'LaborUnion'
      end

      it 'raises ArgumentError if passed something other than an interger or string' do
        expect { Entity.new.send(:name_or_id_to_name, []) } .to raise_error(ArgumentError)
      end

      it 'raises ArgumentError if passed invalid name' do
        expect { Entity.new.send(:name_or_id_to_name, 'i am not an extension') } .to raise_error(ArgumentError)
      end

      it 'raises ArgumentError if passed invalid def id' do
        expect { Entity.new.send(:name_or_id_to_name, 1000) }.to raise_error(ArgumentError)
      end
    end

    describe '#has_extension?' do

      it 'works if provided extension name' do
        org = create(:org)
        org.add_extension('School')
        expect(org.has_extension?('School')).to be true
        expect(org.has_extension?('LaborUnion')).to be false
      end
      
      it 'works if provided def id' do
        org = create(:org)
        org.add_extension('Business')
        expect(org.has_extension?(5)).to be true
        expect(org.has_extension?(7)).to be false
      end

      it 'rasises error if passed invalid name or id' do
        org = create(:org)
        expect { org.has_extension?(100) }.to raise_error(ArgumentError)
        expect { org.has_extension?('eh') }.to raise_error(ArgumentError)
      end
    end

    describe 'remove_extension' do
      it 'removes extension records' do
        org = create(:org)
        expect(org.extension_records.count).to eq 1
        org.add_extension('IndustryTrade')
        expect(org.extension_records.count).to eq 2
        org.remove_extension('IndustryTrade')
        expect(org.extension_records.count).to eq 1
      end

      it 'removes extension records and their models' do
        person = create(:person)
        expect(person.extension_records.count).to eq 1
        expect(person.political_candidate).to be nil
        person.add_extension('PoliticalCandidate')
        expect(person.extension_records.count).to eq 2
        expect(person.political_candidate).to be_a PoliticalCandidate
        person.remove_extension('PoliticalCandidate')
        expect(person.extension_records.count).to eq 1
        expect(person.reload.political_candidate).to be nil
      end

      it 'can be run multiple times' do
        person = create(:person)
        expect { person.add_extension('PoliticalCandidate') }.to change { PoliticalCandidate.count }.by(1)
        expect { person.add_extension('PoliticalCandidate') }.not_to change { PoliticalCandidate.count }
        expect { person.remove_extension('PoliticalCandidate') }.to change { PoliticalCandidate.count }.by(-1)
        expect { person.remove_extension('PoliticalCandidate') }.not_to change { PoliticalCandidate.count }
      end

      it 'nothing happens if the extension does not exist' do
        org = create(:org)
        expect { org.remove_extension('LaborUnion') }.not_to change { ExtensionRecord.count }
        expect { org.remove_extension('Business') }.not_to change { Business.count }
      end

      it 'prevents you from removing primary extensions' do
        expect { build(:org).remove_extension('Org') }.to raise_error(ArgumentError)
        expect { build(:person).remove_extension('Person') }.to raise_error(ArgumentError)
      end
    end

    describe '#add_extensions_by_def_ids' do
      it 'creates extension records' do
        org = create(:org)
        expect(org.extension_records.count).to eq 1
        org.add_extensions_by_def_ids([23, 24])
        expect(org.extension_records.count).to eq 3
      end

      it 'will not create duplicate records' do
        org = create(:org)
        expect { org.add_extensions_by_def_ids([23, 24]) }.to change { org.extension_records.count }.by(2)
        expect { org.add_extensions_by_def_ids([23, 24]) }.not_to change { org.extension_records.count }
      end

      it 'creates extension model if needed for org' do
        org = create(:org)
        expect(org.business).to be nil
        org.add_extensions_by_def_ids([5])
        expect(org.business).to be_a Business
      end
    end

    describe '#remove_extensions_by_def_ids' do
      before do
        @org = create(:org)
        @org.add_extension('School')
        @org.add_extension('NonProfit')
      end

      it 'removes extension records' do
        expect { @org.remove_extensions_by_def_ids([7, 10]) }.to change { ExtensionRecord.count }.by(-2)
      end

      it 'removes extension model' do
        expect { @org.remove_extensions_by_def_ids([7, 10]) }.to change { School.count }.by(-1)
      end

      it 'silently ignores extensions that do not exist' do
        expect { @org.remove_extensions_by_def_ids([7, 10, 9]) }.to change { ExtensionRecord.count }.by(-2)
      end
    end
  end # end Extension Attributes Functions

  describe 'basic_info' do
    context 'is a person' do
      let(:person_with_female_gender) { build(:person, person: build(:a_person, gender_id: 1)) }
      let(:person_with_unknown_gender) { build(:person, person: build(:a_person, gender_id: nil)) }

      it 'contains types' do
        expect(person_with_female_gender.basic_info).to have_key(:types)
      end

      it 'contains gender if person has a gender_id' do
        expect(person_with_female_gender.basic_info).to have_key :gender
        expect(person_with_female_gender.basic_info.fetch(:gender)).to eq 'Female'
      end

      it 'does not contain gender if person does not have a gender_id' do
        expect(person_with_unknown_gender.basic_info).not_to have_key :gender
      end
    end
  end

  describe 'primary_alias' do
    before { @org = create(:org) }

    it 'returns the primary alias' do
      primary_a = @org.aliases[0]
      @org.aliases.create(name: 'other name')
      expect(@org.aliases.count).to eql 2
      expect(@org.primary_alias).to eql primary_a
    end
  end

  describe 'Using paper_trail for versision' do
    with_versioning do
      it 'creates version after updating name' do
        human = create(:person)
        expect(human.versions.size).to eq 1
        expect { human.update(name: 'Emiliano Zapata') }.to change { human.versions.size }.by(1)
      end

      it 'does not create a version after changing updated_at' do
        human = create(:person)
        expect { human.touch }.not_to change { human.versions.size }
      end

      it 'does not create a version after changing link_count' do
        human = create(:person)
        expect { human.update(link_count: 10) }.not_to change { human.versions.size }
      end
    end
  end
end
