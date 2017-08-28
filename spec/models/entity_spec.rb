# coding: utf-8
require 'rails_helper'

describe Entity do
  before(:all) {  DatabaseCleaner.start }
  after(:all)  {  DatabaseCleaner.clean }

  def public_company
    org = create(:org)
    org.aliases.create!(name: 'another name')
    Relationship.create!(entity: org, related: create(:person), category_id: 12)
    org.add_extension('PublicCompany')
    org
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

  describe '#soft_delete' do
    it 'sets is_deleted to be true' do
      org = create(:org)
      expect(org.is_deleted).to be false
      org.soft_delete
      expect(org.is_deleted).to be true
    end

    it 'deletes aliases' do
      org = create(:org)
      a = org.aliases.create!(name: 'my other org name')
      expect { org.soft_delete }.to change { Alias.count }.by(-2)
      expect(Alias.find_by_id(a.id)).to be nil
    end

    it 'deletes Primary extension for person' do
      entity = create(:person)
      expect { entity.soft_delete }.to change { Person.count }.by(-1)
    end

    it 'deletes Primary extension for org' do
      entity = create(:org)
      expect { entity.soft_delete }.to change { Org.count }.by(-1)
    end

    it 'deletes Extension models' do
      person = create(:person, name: 'johnny business')
      person.add_extension('BusinessPerson', sec_cik: 987)
      expect { person.soft_delete }.to change { BusinessPerson.count }.by(-1)
    end

    it 'soft deletes associated images' do
      org = create(:org)
      image = create(:image, entity: org)
      expect { org.soft_delete }.to change { Image.unscoped.find(image.id).is_deleted }.to(true)
    end

    it 'deletes extension records' do
      org = create(:org)
      expect { org.soft_delete }.to change { ExtensionRecord.count }.by(-1)
    end

    it 'soft deletes list entities (including removing from network)' do
      org = create(:org)
      list = create(:list)
      list_entity = ListEntity.create!(list_id: list.id, entity_id: org.id)
      expect { org.soft_delete }.to change { ListEntity.count }.by(-2)
      expect(ListEntity.find_by_id(list_entity.id)).to be nil
    end

    it 'update list timestamp of soft deleting list entities' do
      org = create(:org)
      list = create(:list)
      ListEntity.create!(list_id: list.id, entity_id: org.id)
      list.update_column(:updated_at, 1.day.ago)
      org.soft_delete
      expect(List.find(list.id).updated_at).to be > 1.day.ago
    end

    it 'soft deletes associated relationships' do
      org = create(:org)
      rel = Relationship.create!(entity: org, related: create(:person), category_id: 12)
      expect(Relationship.find(rel.id).is_deleted).to be false
      org.soft_delete
      expect(Relationship.unscoped.find(rel.id).is_deleted).to be true
    end

    describe 'soft delete versioning' do
      with_versioning do
        before { @org = create(:org) }

        it 'creates two versions: one for the Org model and one for the Entity model' do
          expect { @org.soft_delete }.to change { PaperTrail::Version.count }.by(2)
        end

        it 'sets the event type of the version to be soft_delete' do
          @org.soft_delete
          expect(@org.versions.last.event).to eq 'soft_delete'
        end

        describe 'association data' do
          before do
            @public_company = public_company
          end

          it 'saves and stores association data' do
            @public_company.soft_delete
            expect(@public_company.versions.last.association_data).not_to be nil
            data = YAML.load(@public_company.versions.last.association_data)
            expect(data['extension_ids']).to eql [2, 13]
            expect(data['relationship_ids'].length).to eql 1
            expect(data['aliases']).to eql ['another name']
          end
        end
      end
    end
  end

  describe 'get_association_data' do
    before(:all) { @data = public_company.get_association_data }

    it 'has extension ids' do
      expect(@data['extension_ids']).to eql [2, 13]
    end

    it 'has relationship_ids' do
      expect(@data['relationship_ids'].length).to eql 1
    end

    it 'has aliases' do
      expect(@data['aliases']).to eql ['another name']
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
        expect(Entity.sqlize_array(%w(123 456 789))).to eql("('123','456','789')")
      end
    end

    describe 'name_query_string' do
      it 'returns correct string if length of names is 1' do
        expect(Entity.name_query_string([{}])).to eql ' (name_first = ? and name_last = ?) '
      end

      it 'returns correct string if length of names is > 1' do
        expect(Entity.name_query_string([{}, {}])).to eql " (name_first = ? and name_last = ?) OR (name_first = ? and name_last = ?) "
        expect(Entity.name_query_string([{}, {}, {}])).to eql " (name_first = ? and name_last = ?) OR (name_first = ? and name_last = ?) OR (name_first = ? and name_last = ?) "
      end
    end

    describe '#potential_contributions' do
    end

    describe '#contribution_info' do
      before(:all) do
        @elected = create(:elected)
      end
      context 'entity is a person' do
        before(:all) do
          @donor = create(:person)
          @match1 = create(:os_match, os_donation: create(:os_donation), donor_id: @donor.id)
          @match2 = create(:os_match, os_donation: create(:os_donation), donor_id: @donor.id)
          @match3 = create(:os_match, os_donation: create(:os_donation), donor_id: (@donor.id + 100)) # does not match for donor
        end

        it 'returns 2 matches for donor' do
          expect(@donor.contribution_info.length).to eq 2
        end

        it 'returns OsMatch' do
          expect(@donor.contribution_info[0]).to be_a OsMatch
        end
      end

      context 'entity is an org' do
        before(:all) do
          @org = create(:org)
          @person1 = create(:person)
          @person2 = create(:person)
          @person3 = create(:person)
          [@person1, @person2].each { |p| Relationship.create!(category_id: 1, entity: p, related: @org) }
          Relationship.create!(category_id: 12, entity: @person3, related: @org)
          @match1 = create(:os_match, os_donation: create(:os_donation), donor_id: @person1.id)
          @match2 = create(:os_match, os_donation: create(:os_donation), donor_id: @person2.id)
          @match3 = create(:os_match, os_donation: create(:os_donation), donor_id: @person3.id) # does not match
        end

        it 'returns 2 matches for org' do
          expect(@org.contribution_info.length).to eq 2
        end
      end
    end
  end # end political

  describe 'Extension Attributes Functions' do
    def create_school
      school = create(:org, name: 'private school')
      school.add_extension 'School', is_private: true
      school
    end

    def without_ids(array)
      array.reject { |c| c == 'id' || c == 'entity_id' }
    end


    describe '#primary_extension_model' do
      before(:all) do
        @org = create(:org)
        @person = create(:person)
      end

      it 'returns Org if entity is an org' do
        expect(@org.primary_extension_model).to be_a Org
        expect(@person.primary_extension_model).not_to be_a Org
      end

      it 'returns Person if entity is a person' do
        expect(@org.primary_extension_model).not_to be_a Person
        expect(@person.primary_extension_model).to be_a Person
      end
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

    describe '#extension_models' do
      before(:all) do
        @person = create(:person)
        @person.add_extension('Lawyer')
        @person.add_extension('PoliticalCandidate')
      end

     it 'returns array' do
       expect(@person.extension_models).to be_a Array
       expect(@person.extension_models.length).to eq 2
     end

     it 'has Org and PoliticalCandidate models' do
       expect(@person.extension_models[0]).to be_a Person
       expect(@person.extension_models[1]).to be_a PoliticalCandidate
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

  describe 'EntityPaths' do
    describe 'Entity.legacy_url' do
      it 'generates correct url' do
        url = Entity.legacy_url('Org', 123, 'cat whisperers inc')
        expect(url).to eq '/org/123/cat_whisperers_inc'
      end

      it 'generates correct url with action' do
        url = Entity.legacy_url('Org', 123, 'cat whisperers inc', 'edit')
        expect(url).to eq '/org/123/cat_whisperers_inc/edit'
      end

      it 'works as an instance method' do
        e = build(:org, name: 'some corp', id: 1000)
        expect(e.legacy_url).to eq "/org/1000/some_corp"
      end
    end

    describe 'Entity.name_to_legacy_slug' do
      it 'removes spaces' do
        expect(Entity.name_to_legacy_slug('cool name')).to eq 'cool_name'
      end

      it 'removes slashes' do
        expect(Entity.name_to_legacy_slug('cool /name')).to eq 'cool_~name'
      end

      it 'removes plus signs' do
        expect(Entity.name_to_legacy_slug('+corp')).to eq '_corp'
      end
    end
  end

  # this is defined in models/concerns/similar_entities.rb
  describe '#similar_entities' do

    before do
      @e = build(:org)
    end
    
    it 'calls Entity.search and generate_search_terms' do
      expect(@e).to receive(:generate_search_terms).once.and_return("(search terms)")
      expect(Entity).to receive(:search)
                         .with("@!summary (search terms)", any_args).and_return(['response'])
      expect(@e.similar_entities).to eq ['response']
    end

    it 'can rescue from ThinkingSphinx::QueryError' do
      allow(@e).to receive(:generate_search_terms).and_return("(search terms)")
      expect(Entity).to receive(:search).and_raise(ThinkingSphinx::QueryError)
      expect(@e.similar_entities).to eql []
    end

    it 'can rescue from ThinkingSphinx::SyntaxError' do
      allow(@e).to receive(:generate_search_terms).and_return("(search terms)")
      expect(Entity).to receive(:search).and_raise(ThinkingSphinx::SyntaxError)
      expect(@e.similar_entities).to eql []
    end

    it 'can rescue from ThinkingSphinx::ConnectionError' do
      allow(@e).to receive(:generate_search_terms).and_return("(search terms)")
      expect(Entity).to receive(:search).and_raise(ThinkingSphinx::ConnectionError)
      expect(@e.similar_entities).to eql []
    end

    it 'raises other errors' do
      e = build(:org)
      allow(e).to receive(:generate_search_terms).and_return("(search terms)")
      expect(Entity).to receive(:search).and_raise(ArgumentError)
      expect { e.similar_entities }.to raise_error(ArgumentError)
    end

    describe 'generate_search_terms' do

      it 'generates list of names for org' do
        e = build(:org, name: 'one')
        aliases = [build(:alias, name: 'one', is_primary: true), build(:alias, name: 'two')]
        expect(e).to receive(:aliases).and_return(aliases)
        expect(e.send(:generate_search_terms)).to eq "(one) | (two) | (*one*)"
      end

      it 'property escapes names with slashes' do
        e = build(:org, name: 'weird/name')
        aliases = [build(:alias, name: 'weird/name', is_primary: true), build(:alias, name: 'name')]
        expect(e).to receive(:aliases).and_return(aliases)
        expect(e.send(:generate_search_terms)).to eq "(weird\\/name) | (name) | (*weird\\/name*)"
      end

    end
  end

  describe 'Helpers' do
    describe 'person?' do
      it 'returns true if entity is a person' do
        expect(build(:person).person?).to be true
        expect(build(:org).person?).to be false
      end
    end

    describe 'org?' do
      it 'returns true if entity is an org' do
        expect(build(:person).org?).to be false
        expect(build(:org).org?).to be true
      end
    end

    describe 'school?' do
      it 'returns true if org is a school' do
        org = create(:org)
        org.add_extension('School')
        expect(org.school?).to be true
      end

      it 'returns false if org is not a school' do
        org = create(:org)
        org.add_extension('IndustryTrade')
        expect(org.school?).to be false
      end

      it 'returns false for people' do
        expect(build(:person).school?).to be false
      end
    end
  end

  describe 'EntitySearch' do
    describe 'Entity::Search.search' do
      let(:defaults) {{ match_mode: :extended,
                        with: {is_deleted: false},
                        per_page: 15,
                        select: '*, weight() * (link_count + 1) AS link_weight',
                        order: 'link_weight DESC' }}

      it 'calls Entity.search with defaults' do
        expect(Entity).to receive(:search)
                           .with('@(name,aliases) someone', defaults)
        Entity::Search.search 'someone'
      end

      it 'accept hash as second arg to overrides defaults' do
        expect(Entity).to receive(:search)
                           .with('@(name,aliases) someone', defaults.merge(per_page: 5))
        Entity::Search.search 'someone', num: 5
      end
    end

    describe 'entity_with_summary' do
      it 'returns hash with summary field' do
        e = build(:person, summary: 'i am a summary')
        h = Entity::Search.entity_with_summary(e)
        expect(h).to include :summary => 'i am a summary'
      end
    end

    describe 'entity_no_summary' do
      it 'returns hash without summary field' do
        e = build(:person, summary: 'i am a summary')
        h = Entity::Search.entity_no_summary(e)
        expect(h).to be_a Hash
        expect(h).not_to include :summary => 'i am a summary'
      end
    end
  end

  describe 'Tagging' do
    it 'can tag a person with oil' do
      person = create(:person)
      expect { person.tag('oil') }.to change { Tagging.count }.by(1)
      expect(person.taggings).to eq [Tagging.last]
    end
  end


  describe 'Using paper_trail for versision' do
    with_versioning do
      it 'creates version after updating name' do
        human = create(:person)
        expect(human.versions.size).to eq 1
        expect { human.update(name: 'Emiliano Zapata') }.to change { human.versions.size }.by(1)
        expect(human.versions.last.event).to eq 'update'
      end

      it 'does not store association_data for update event' do
        human = create(:person)
        human.update!(blurb: 'マルクスの思想の中心は、史的唯物論である。')
        expect(human.versions.last.event).to eq 'update'
        expect(human.versions.last.association_data).to be nil
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
