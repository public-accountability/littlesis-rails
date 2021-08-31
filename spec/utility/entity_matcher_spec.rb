# frozen_string_literal: true

describe EntityMatcher, :sphinx do
  def result_person(*args)
    EntityMatcher::EvaluationResult::Person.new.tap do |er|
      args.each { |x| er.send("#{x}=", true) }
    end
  end

  def result_org(*args)
    EntityMatcher::EvaluationResult::Org.new.tap do |er|
      args.each { |x| er.send("#{x}=", true) }
    end
  end

  describe 'Search' do
    # creates a sample set of 5 people: 2 Vibes, 2 Traverses, and 1 Chum of chance
    before do
      setup_sphinx
      @chum = EntitySpecHelpers.chums(num: 1).first
      @chum.aliases.create!(name: 'Louis Deschamps')
      @chum.person.update!(name_nick: 'Balloonist')
      @entities = EntitySpecHelpers.bad_vibes(num: 2) + EntitySpecHelpers.traverses(num: 2) + Array.wrap(@chum)
    end

    after do
      teardown_sphinx
    end

    describe 'searching for a chum' do
      it 'finds by alias' do
        subject = EntityMatcher::Search.by_name('Deschamps', primary_ext: 'Person')
        expect(subject.length).to eq 1
        expect(subject.first).to eq @chum
      end

      it 'finds by nickname' do
        subject = EntityMatcher::Search.by_name('Balloonist', primary_ext: 'Person')
        expect(subject.length).to eq 1
        expect(subject.first).to eq @chum
      end
    end

    describe 'searching using a person' do
      specify do
        expect(EntityMatcher::Search.by_entity(@entities.first).count).to eq 1
      end
    end

    describe 'last name search' do
      it 'finds 2 traverses' do
        expect(EntityMatcher::Search.by_name('traverse', primary_ext: 'Person').count).to eq 2
      end

      it 'finds 2 traverses if other names are also included in the search' do
        expect(EntityMatcher::Search.by_name('traverse', 'randomname', primary_ext: 'Person').count)
          .to eq 2
      end

      it 'finds 2 vibes' do
        expect(EntityMatcher::Search.by_name('vibe', primary_ext: 'Person').count).to eq 2
      end

      it 'finds vibes and traverses at once' do
        expect(EntityMatcher::Search.by_name('traverse', 'vibe', primary_ext: 'Person').count).to eq 4
      end
    end
  end

  describe 'Query' do
    describe 'Org string ' do
      subject { EntityMatcher::Query.org_name(name) }

      describe 'simple name' do
        specify do
          expect(EntityMatcher::Query.org_name("simplecorp"))
            .to eq "(*simplecorp*)"
        end
      end

      describe 'simple name with suffix' do
        specify do
          expect(EntityMatcher::Query.org_name("SimpleCorp llc"))
            .to eq "(*simplecorp* *llc*) | (simplecorp)"
        end

      end

      describe 'long name with essential words' do
        specify do
          expect(EntityMatcher::Query.org_name("American Green Tomatoes Corp"))
            .to eq "(*american* *green* *tomatoes* *corp*) | (american green tomatoes) | (green tomatoes)"
        end
      end
    end

    describe 'Person' do
      subject { EntityMatcher::Query.entity(entity) }

      let(:names) { [] }
      let(:entity) { EntitySpecHelpers.person(*names) }
      let(:person) { entity.person }

      context 'when person has first and last name only' do
        it { is_expected.to eql "(#{entity.name})" }
      end

      context 'when person has first, last, and middle names' do
        let(:names) { ['middle'] }

        it { is_expected.to eql "(#{entity.name}) | (#{person.name_first} #{person.name_last})" }
      end

      context 'when person has first, last, middle, and suffix' do
        let(:names) { %w[middle suffix] }
        let(:person) { entity.person }

        it do
          is_expected.to eql "(#{entity.name}) | (#{person.name_first} #{person.name_last}) | (#{person.name_first} #{person.name_last} #{person.name_suffix})"
        end
      end

      context 'when person has first, last, middle, prefix and suffix' do
        let(:names) { %w[middle prefix suffix] }

        it do
          is_expected
            .to eq "(#{entity.name}) | (#{person.name_first} #{person.name_last}) | (#{person.name_first} #{person.name_last} #{person.name_suffix}) | (#{person.name_prefix} #{person.name_first} #{person.name_last})"
        end
      end
    end

    describe 'query: single name' do
      subject { EntityMatcher::Query.names('Thoreau').to_s }

      it { is_expected.to eql "(*Thoreau*)" }
    end

    describe 'query: two names' do
      subject { EntityMatcher::Query.names('bob', 'alice').to_s }

      it { is_expected.to eql "(*bob*) | (*alice*)" }
    end

    describe  'query: two names in an array' do
      subject { EntityMatcher::Query.names(%w[bob alice]).to_s }

      it { is_expected.to eql "(*bob*) | (*alice*)" }
    end
  end

  describe 'TestCase' do
    describe 'class methods' do
      specify do
        test_case = EntityMatcher::TestCase.org("Corporation", keywords: ['oil'])
        expect(test_case).to be_a EntityMatcher::TestCase::Org
        expect(test_case.keywords).to eq ['oil']
      end

      specify do
        test_case = EntityMatcher::TestCase.person("Albert Camus")
        expect(test_case).to be_a EntityMatcher::TestCase::Person
        expect(test_case.keywords).to eq []
      end
    end

    describe EntityMatcher::TestCase::Org do
      subject { EntityMatcher::TestCase::Org }

      let(:org) { build(:org, :with_org_name) }

      it 'sets @entity' do
        expect(subject.new(org).entity).to be_a Entity
        expect(subject.new('corp').entity).to be nil
      end

      it 'sets @name for a string' do
        expect(subject.new(Faker::Company.name).name).to be_a OrgName::Name
      end

      it 'sets @name for a string' do
        expect(subject.new(org).name).to be_a OrgName::Name
      end
    end

    describe EntityMatcher::TestCase::Person do
      subject { EntityMatcher::TestCase::Person }

      let(:name) { Faker::Name.name }
      let(:person) { build(:person, :with_person_name, person: build(:a_person)) }
      let(:persisted_person) { create(:entity_person, :with_person_name) }

      it 'sets @entity for entities' do
        expect(subject.new(person).entity).to be_a Entity
        expect(subject.new(name).entity).to be nil
      end

      it 'sets name when provided entity' do
        expect(subject.new(persisted_person).name)
          .to eql ActiveSupport::HashWithIndifferentAccess
                    .new(persisted_person.person.name_attributes)
      end

      it 'sets name when provided string' do
        expect(subject.new(name).name)
          .to eql NameParser.new(name).to_indifferent_hash
      end

      it 'if passed a name with only one word, it is assumed to be the last name' do
        expect(subject.new('smith').name)
          .to eql ActiveSupport::HashWithIndifferentAccess
                    .new(name_prefix: nil, name_first: nil,
                         name_middle: nil, name_last: 'Smith',
                         name_suffix: nil, name_nick: nil)
      end

      it 'sets name when provided hash' do
        expect(subject.new({'name_last' => 'Last', 'name_first' => 'First'}).name)
          .to eql ActiveSupport::HashWithIndifferentAccess
                    .new(name_prefix: nil,
                         name_first: "First",
                         name_middle: nil,
                         name_last: "Last",
                         name_suffix: nil,
                         name_nick: nil)
      end

      it 'raises error if called with the wrong entity type' do
        expect { subject.new(build(:org)) }
          .to raise_error(EntityMatcher::TestCase::WrongEntityTypeError)
      end

      it 'raises error if called with an hash missing a last name' do
        expect { subject.new({ first_name: 'xyz' }) }
          .to raise_error(EntityMatcher::TestCase::InvalidPersonHash)
      end
    end
  end

  describe 'Evaluation' do
    describe 'argument validation' do
      subject { EntityMatcher::Evaluation::Person }

      def generate_test_case
        EntityMatcher::TestCase::Person.new(
          build(:person, person: build(:a_person))
        )
      end

      context 'test_case is invalid' do
        specify do
          expect { subject.new(build(:person), generate_test_case) }
            .to raise_error(TypeError)
        end
      end

      context 'match is invalid' do
        specify do
          expect { subject.new(generate_test_case, EntityMatcher::TestCase::Person.new('first last')) }
            .to raise_error(TypeError)
        end
      end
    end

    describe EntityMatcher::Evaluation::Person do
      subject { EntityMatcher::Evaluation::Person }

      def generate_test_case(fields = {})
        EntityMatcher::TestCase::Person.new(build(:person, person: build(:a_person, **fields)))
      end

      context 'same last names' do
        let(:test_case) do
          EntityMatcher::TestCase::Person.new('jane doe')
        end

        let(:match) do
          generate_test_case name_last: 'Doe'
        end

        specify do
          expect(subject.new(test_case, match).result.same_last_name).to be true
          expect(subject.new(test_case, match).result.same_first_name).to be false
        end
      end

      context 'common last name' do
        let(:test_case) { EntityMatcher::TestCase::Person.new('jane doe') }
        let(:match) { generate_test_case name_last: 'Doe' }
        let(:match_uncommon_name) { generate_test_case name_last: 'uncommon' }

        before do
          Rails.cache.clear
          CommonName.create!(name: 'DOE')
        end

        after { Rails.cache.clear }

        it 'determines if match has a common last name' do
          expect(subject.new(test_case, match).result.common_last_name)
            .to be true
        end

        it 'determines if match has an uncommon last name' do
          expect(subject.new(test_case, match_uncommon_name).result.common_last_name)
            .to be false
        end
      end

      context 'same first name' do
        let(:first_name) { Faker::Name.first_name }
        let(:test_case) do
          EntityMatcher::TestCase::Person.new "#{first_name} #{Faker::Name.unique.last_name}"
        end

        let(:test_case_without_last_name) do
          EntityMatcher::TestCase::Person.new 'Cat'
        end

        let(:match) do
          generate_test_case name_first: first_name, name_last: Faker::Name.unique.last_name
        end

        specify do
          expect(subject.new(test_case, match).result.same_first_name).to be true
          expect(subject.new(test_case, match).result.same_last_name).to be false
          expect(subject.new(test_case, match).result.mismatched_middle_name).to be false
        end

        it 'is nil when test case is missing a first name' do
          expect(subject.new(test_case_without_last_name, match).result.same_first_name)
            .to be nil
        end
      end

      context 'same first, middle, and last name' do
        let(:first_name) { Faker::Name.first_name }
        let(:middle_name) { Faker::Name.first_name }
        let(:last_name) { Faker::Name.last_name }
        let(:test_case) do
          EntityMatcher::TestCase::Person.new "#{first_name} #{middle_name} #{last_name}"
        end

        let(:match) do
          generate_test_case name_first: first_name, name_middle: middle_name, name_last: last_name
        end

        specify do
          expect(subject.new(test_case, match).result.same_first_name).to be true
          expect(subject.new(test_case, match).result.same_last_name).to be true
          expect(subject.new(test_case, match).result.same_middle_name).to be true
          expect(subject.new(test_case, match).result.mismatched_middle_name).to be false
          expect(subject.new(test_case, match).result.different_middle_name).to be false
        end
      end

      context 'no middle names' do
        let(:first_name) { Faker::Name.first_name }
        let(:last_name) { Faker::Name.last_name }
        let(:test_case) do
          EntityMatcher::TestCase::Person.new "#{first_name} #{last_name}"
        end

        let(:match) do
          generate_test_case name_first: first_name, name_last: last_name
        end

        specify do
          expect(subject.new(test_case, match).result.same_middle_name).to be nil
          expect(subject.new(test_case, match).result.different_middle_name).to be false
          expect(subject.new(test_case, match).result.mismatched_middle_name).to be false
        end
      end

      context 'same middle initial' do
        let(:first_name) { Faker::Name.first_name }
        let(:middle_name) { 'Alice' }
        let(:last_name) { Faker::Name.last_name }
        let(:test_case) do
          EntityMatcher::TestCase::Person.new "#{first_name} #{middle_name} #{last_name}"
        end

        let(:match) do
          generate_test_case name_first: first_name, name_middle: 'A.', name_last: last_name
        end

        specify do
          expect(subject.new(test_case, match).result.same_middle_name).to eql true
          expect(subject.new(test_case, match).result.different_middle_name).to eql false
          expect(subject.new(test_case, match).result.mismatched_middle_name).to eql false
        end
      end

      context 'mismatched suffix' do
        let(:test_case) do
          EntityMatcher::TestCase::Person.new "#{Faker::Name.first_name} #{Faker::Name.last_name}"
        end

        let(:match) do
          generate_test_case name_first: Faker::Name.first_name, name_suffix: 'JR'
        end

        specify do
          expect(subject.new(test_case, match).result.blurb_keyword).to be_nil
          expect(subject.new(test_case, match).result.same_suffix).to be_nil
          expect(subject.new(test_case, match).result.mismatched_suffix).to be true
        end
      end

      context 'different middle name' do
        let(:test_case) do
          EntityMatcher::TestCase::Person.new "#{Faker::Name.first_name} A #{Faker::Name.last_name}"
        end

        let(:match) do
          generate_test_case name_first: Faker::Name.first_name, name_middle: 'B'
        end

        specify do
          expect(subject.new(test_case, match).result.same_middle_name).to be false
          expect(subject.new(test_case, match).result.mismatched_middle_name).to be true
          expect(subject.new(test_case, match).result.different_middle_name).to be true
        end
      end

      context 'mismatched middle name: more details on match' do
        let(:test_case) do
          EntityMatcher::TestCase::Person.new "#{Faker::Name.first_name} #{Faker::Name.last_name}"
        end

        let(:match) do
          generate_test_case name_first: Faker::Name.first_name, name_middle: 'B'
        end

        specify do
          expect(subject.new(test_case, match).result.same_middle_name).to eql nil
          expect(subject.new(test_case, match).result.mismatched_middle_name).to eql true
        end
      end

      context 'mismatched middle name: more details on test case' do
        let(:first_name) { Faker::Name.first_name }
        let(:last_name) { Faker::Name.last_name }

        let(:test_case) do
          EntityMatcher::TestCase::Person.new "#{first_name} Alice #{last_name}"
        end

        let(:match) do
          generate_test_case name_first: first_name, name_last: last_name
        end

        specify do
          expect(subject.new(test_case, match).result.same_middle_name).to be nil
          expect(subject.new(test_case, match).result.mismatched_middle_name).to be true
        end
      end

      context 'similar first names' do
        let(:test_case) do
          EntityMatcher::TestCase::Person.new 'Cindi Wallanger'
        end

        let(:match) do
          generate_test_case name_first: 'cindy', name_last: 'graham'
        end

        specify do
          expect(subject.new(test_case, match).result.similar_first_name).to be true
          expect(subject.new(test_case, match).result.similar_last_name).to be false
        end
      end

      context 'relationship in common' do
        let(:org) { create(:entity_org) }
        let(:match_entity) do
          create(:entity_person).tap do |entity|
            Relationship.create!(category_id: 12, entity: entity, related: org)
          end
        end
        let(:full_name) { "#{Faker::Name.first_name} #{Faker::Name.last_name}" }
        let(:test_case) do
          EntityMatcher::TestCase::Person.new(full_name, associated: org.id)
        end
        let(:match) { EntityMatcher::TestCase::Person.new(match_entity) }

        specify do
          expect(subject.new(test_case, match).result.common_relationship).to eql true
        end
      end

      context 'no relationship in common' do
        let(:org) { create(:entity_org) }
        let(:other_org) { create(:entity_org) }
        let(:match_entity) do
          create(:entity_person).tap do |entity|
            Relationship.create!(category_id: 12, entity: entity, related: org)
          end
        end
        let(:test_case) do
          EntityMatcher::TestCase::Person.new("#{Faker::Name.first_name} #{Faker::Name.last_name}", associated: other_org.id)
        end
        let(:match) { EntityMatcher::TestCase::Person.new(match_entity) }

        specify do
          expect(subject.new(test_case, match).result.common_relationship).to be false
        end
      end

      describe 'searching blub and summary' do
        context 'does not have keyword in blurb' do
          let(:match_entity) do
            create(:entity_person, blurb: 'blah blah. not a very interesting match')
          end
          let(:test_case) do
            EntityMatcher::TestCase::Person
              .new("#{Faker::Name.first_name} #{Faker::Name.last_name}",
                   associated: '123',
                   keywords: ['oil'])
          end
          let(:match) { EntityMatcher::TestCase::Person.new(match_entity) }

          specify do
            expect(subject.new(test_case, match).result.blurb_keyword).to eql false
          end
        end

        context 'has keyword in blurb' do
          let(:match_entity) do
            create(:entity_person, blurb: 'oil executive')
          end
          let(:test_case) do
            EntityMatcher::TestCase::Person
              .new("#{Faker::Name.first_name} #{Faker::Name.last_name}",
                   associated: '123',
                   keywords: ['oil'])
          end
          let(:match) { EntityMatcher::TestCase::Person.new(match_entity) }

          specify do
            expect(subject.new(test_case, match).result.common_relationship).to be false
            expect(subject.new(test_case, match).result.blurb_keyword).to be true
          end
        end

        context 'has keyword in summary' do
          let(:match_entity) do
            create(:entity_person, summary: 'i am into ruining the planet by extracting oil!')
          end

          let(:test_case) do
            EntityMatcher::TestCase::Person
              .new("#{Faker::Name.first_name} #{Faker::Name.last_name}",
                   associated: '123',
                   keywords: ['oil'])
          end
          let(:match) { EntityMatcher::TestCase::Person.new(match_entity) }

          specify do
            expect(subject.new(test_case, match).result.common_relationship).to be false
            expect(subject.new(test_case, match).result.blurb_keyword).to be true
          end
        end
      end
    end # end EntityMatcher::Evaluation::Person

    describe EntityMatcher::Evaluation::Org do
      let(:entity) { build(:org) }
      # subject { EntityMatcher::Evaluation::Org }

      context 'has same name' do
        let(:test_case) { EntityMatcher::TestCase::Org.new("test company") }
        let(:match) { EntityMatcher::TestCase::Org.new(create(:entity_org, name: "Test Company")) }

        subject { EntityMatcher::Evaluation::Org.new(test_case, match) }

        specify do
          expect(subject.result.same_name).to be true
          expect(subject.result.similar_name).to be true
          expect(subject.result.matches_alias).to be nil
          expect(subject.result.common_relationship).to be nil
        end
      end

      context 'similar name' do
        subject { EntityMatcher::Evaluation::Org.new(test_case, match) }

        let(:test_case) { EntityMatcher::TestCase::Org.new("ABC COMPANY") }
        let(:match) { EntityMatcher::TestCase::Org.new(create(:entity_org, name: "ABCD COMPANY")) }

        specify do
          expect(subject.result.same_name).to be false
          expect(subject.result.similar_name).to be true
        end
      end

      context 'same root' do
        subject { EntityMatcher::Evaluation::Org.new(test_case, match) }

        let(:test_case) { EntityMatcher::TestCase::Org.new("ABC COMPANY") }
        let(:match) { EntityMatcher::TestCase::Org.new(create(:entity_org, name: "ABC LLC")) }

        specify do
          expect(subject.result.same_name).to be false
          expect(subject.result.similar_name).to be false
          expect(subject.result.same_root).to be true
        end
      end

      context 'simmilar root' do
        subject { EntityMatcher::Evaluation::Org.new(test_case, match) }

        let(:test_case) { EntityMatcher::TestCase::Org.new("123 COMPANY") }
        let(:match) { EntityMatcher::TestCase::Org.new(create(:entity_org, name: "124 LLC")) }

        specify do
          expect(subject.result.same_root).to eql false
          expect(subject.result.similar_root).to eql true
        end
      end

      context 'matches alias' do
        subject { EntityMatcher::Evaluation::Org.new(test_case, match) }

        let(:test_case) { EntityMatcher::TestCase::Org.new("123 COMPANY") }
        let(:entity) do
          create(:entity_org, :with_org_name).tap do |e|
            e.aliases.create!(name: '123 company')
          end
        end
        let(:match) { EntityMatcher::TestCase::Org.new(entity) }

        specify do
          expect(subject.result.same_name).to be false
          expect(subject.result.similar_name).to be false
          expect(subject.result.matches_alias).to be true
        end
      end

      context 'relationship in common' do
        let(:other_org) { create(:entity_org) }
        let(:test_case) { EntityMatcher::TestCase::Org.new("123 COMPANY", associated: other_org.id) }
        let(:entity) do
          create(:entity_org, :with_org_name).tap do |e|
            Relationship.create!(category_id: 12, entity: e, related: other_org)
          end
        end
        let(:match) { EntityMatcher::TestCase::Org.new(entity) }
        subject { EntityMatcher::Evaluation::Org.new(test_case, match) }

        specify do
          expect(subject.result.common_relationship).to be true
        end
      end
    end # end EntityMatcher::Evaluation::Org

    describe 'EvalutionResult #as_json' do
      let(:person) { build(:person) }

      subject(:evaluation_result) do
        result_person(:same_last_name, :same_first_name).tap do |rp|
          rp.entity = person
        end
      end

      specify do
        expect(evaluation_result.as_json)
          .to eql('entity' => person.to_hash(image_url: true, image_url_type: 'small', except: %w[notes delta last_user_id]),
                  'values' => [:same_last_name, :same_first_name],
                  'ranking' => 55,
                  'automatch' => false)
      end
    end

    describe EntityMatcher::EvaluationResult::Person do
      describe 'values' do
        subject { result_person(:same_last_name, :same_first_name) }

        it 'returns attributes, ignoring entity' do
          subject.entity = build(:person)
          expect(subject.values).to eq Set[:same_last_name, :same_first_name]
        end
      end

      describe 'does not check entity when comparing equality' do
        it 'having the same properies are equal' do
          expect(result_person(:same_first_name, :same_last_name) == result_person(:same_first_name, :same_last_name)).to be true
          expect(result_person(:same_first_name, :same_last_name).eql?(result_person(:same_first_name, :same_last_name))).to be true
          expect(result_person(:same_first_name, :similar_last_name) == result_person(:same_first_name, :same_last_name)).to be false
          expect(result_person(:same_first_name, :similar_last_name).eql?(result_person(:same_first_name, :same_last_name))).to be false
        end

        it 'having the same properies are equal even if entityies are different' do
          entity1 = build(:org, :with_org_name)
          entity2 = build(:org, :with_org_name)

          person1 = result_person(:same_first_name, :same_last_name)
          person1.entity = entity1
          person2 = result_person(:same_first_name, :same_last_name)
          person2.entity = entity2
          expect(person1 == person2).to be true
          expect(person1.eql? person2).to be true
        end
      end

      describe 'person: automatchable? and automatch?' do
        context 'can be automatch' do
          subject { result_person(:same_first_name, :same_last_name, :common_relationship, :same_middle_name) }
          specify { expect(subject.automatch?).to be true }
        end

        describe 'can be automatched if last_name is uncommon' do
          subject do
            result_person(:same_first_name, :same_last_name).tap do |rp|
              rp.common_last_name = false
            end
          end

          specify { expect(subject.automatch?).to be true }
        end

        context 'cannot be automatched if last_name is uncommon with a mismatched suffix' do
          subject do
            result_person(:same_first_name, :same_last_name, :mismatched_suffix).tap do |rp|
              rp.common_last_name = false
            end
          end
          specify { expect(subject.automatch?).to be false }
        end

        context 'cannot be automatched if last_name is uncommon with a mismatched middle name' do
          subject do
            result_person(:same_first_name, :same_last_name, :mismatched_middle_name).tap do |rp|
              rp.common_last_name = false
            end
          end
          specify { expect(subject.automatch?).to be false }
        end

        context 'cannot be automatched if last name is common' do
          subject do
            result_person(:same_first_name, :same_last_name).tap do |rp|
              rp.common_last_name = true
            end
          end

          specify { expect(subject.automatch?).to be false }
        end

        context 'cannot be automatched if commonality is unknown' do
          subject { result_person(:same_first_name, :same_last_name) }

          specify { expect(subject.automatch?).to be false }
        end

        context 'cannot be automatched' do
          subject { result_person(:same_first_name, :same_last_name, :blurb_keyword) }

          specify { expect(subject.automatch?).to be false }
        end
      end

      describe 'org: automatch' do
        context 'can be automatch' do
          subject { result_org(:matches_alias) }

          specify { expect(subject.automatch?).to be true }
        end

        context 'can not be automatch' do
          subject { result_org(:same_root) }
          specify { expect(subject.automatch?).to be false }
        end
      end

      it 'set is not automatchable if it has too many matches' do
        results = [
          result_person(:similar_first_name, :similar_last_name),
          result_person(:same_first_name, :same_last_name, :common_relationship, :same_middle_name),
          result_person(:similar_first_name, :same_last_name, :common_relationship)
        ]
        expect(EntityMatcher::EvaluationResultSet.new(results).automatchable?).to be false
      end

      it 'set is not automatchable if it has no matches' do
        results = [result_org(:similar_name), result_org(:same_root, :blurb_keyword), result_org(:same_root)]
        expect(EntityMatcher::EvaluationResultSet.new(results).automatchable?).to be false
      end

      it 'set is not automatchable if it has no matches' do
        results = [result_org(:similar_name), result_org(:same_root, :blurb_keyword), result_org(:same_root)]
        expect(EntityMatcher::EvaluationResultSet.new(results).automatchable?).to be false
      end

      it 'works with zero or one matches' do
        expect(EntityMatcher::EvaluationResultSet.new([result_org(:same_name)]).automatchable?).to be true
        expect(EntityMatcher::EvaluationResultSet.new([result_org(:same_name), result_org(:same_name)]).automatchable?).to be false
        expect(EntityMatcher::EvaluationResultSet.new([result_org(:same_name), result_org(:same_name)]).automatch).to be_nil
        expect(EntityMatcher::EvaluationResultSet.new([]).automatchable?).to be nil
      end

      it 'set is automatachable if it only one match' do
        results = [
          result_org(:same_name, :common_relationship),
          result_org(:same_root, :blurb_keyword),
          result_org(:same_root)
        ]
        expect(EntityMatcher::EvaluationResultSet.new(results).automatchable?).to be true
        expect(EntityMatcher::EvaluationResultSet.new(results).automatch).to be_a EntityMatcher::EvaluationResult::Org
      end
    end

    describe 'filter' do
      let(:results) do
        [
          result_person(:same_first_name, :same_last_name, :same_middle_name, :common_relationship),
          result_person(:same_first_name, :same_last_name),
          result_person(:same_first_name, :similar_last_name, :blurb_keyword)
        ]
      end

      let(:result_set) { EntityMatcher::EvaluationResultSet.new(results) }

      it 'filters based on a single category' do
        expect(result_set.filter(:same_last_name).to_a)
          .to eq([
                   result_person(:same_first_name, :same_last_name, :same_middle_name, :common_relationship),
                   result_person(:same_first_name, :same_last_name)
                 ])
      end

      it 'filters with 2 categories' do
        expect(result_set.filter(:same_last_name, :common_relationship).to_a)
          .to eq([result_person(:same_first_name, :same_last_name, :same_middle_name, :common_relationship)])
      end

      it 'can include all results' do
        expect(result_set.filter(:same_first_name).to_a).to eq(results)
      end

      it 'can filter out all results' do
        expect(result_set.filter(:same_middle_name, :blurb_keyword).to_a).to eq([])
      end

      it 'rejects arguments that are not a valid attribute' do
        expect { result_set.filter(:wearing_silly_hat) }.to raise_error(ArgumentError)
      end
    end

    describe 'Sorting People' do
      describe 'same first_and_last' do
        let(:results) do
          [
            result_person(:same_first_name, :same_last_name, :same_middle_name, :common_relationship),
            result_person(:same_first_name, :same_last_name, :common_relationship),
            result_person(:same_first_name, :same_last_name, :blurb_keyword),
            result_person(:same_first_name, :same_last_name, :same_middle_name, :same_prefix, :same_suffix),
            result_person(:same_first_name, :same_last_name, :same_middle_name, :same_prefix),
            result_person(:same_first_name, :same_last_name, :same_middle_name),
            result_person(:same_first_name, :similar_last_name, :same_suffix)
          ]
        end

        it 'sorts array' do
          3.times do
            sorted = EntityMatcher::EvaluationResultSet.new(results.shuffle).to_a
            expect(sorted).to eql results
          end
        end
      end

      describe 'same_first_similar_last' do
        let(:results) do
          [
            result_person(:same_first_name, :similar_last_name, :same_middle_name, :same_prefix, :common_relationship),
            result_person(:same_first_name, :similar_last_name, :common_relationship),
            result_person(:same_first_name, :similar_last_name, :same_middle_name, :same_prefix, :blurb_keyword),
            result_person(:same_first_name, :similar_last_name, :same_suffix, :blurb_keyword),
            result_person(:same_first_name, :similar_last_name, :blurb_keyword),
            result_person(:same_first_name, :similar_last_name, :same_middle_name, :same_prefix, :same_suffix),
            result_person(:same_first_name, :similar_last_name)
          ]
        end

        it 'sorts array' do
          3.times do
            sorted = EntityMatcher::EvaluationResultSet.new(results.shuffle).to_a
            expect(sorted).to eq results
          end
        end
      end

      describe 'similar first and similar last' do
        let(:results) do
          [
            result_person(:same_first_name, :same_last_name),
            result_person(:same_first_name, :similar_last_name),
            result_person(:similar_first_name, :similar_last_name, :common_relationship, :blurb_keyword),
            result_person(:similar_first_name, :similar_last_name, :same_middle_name, :same_prefix, :common_relationship),
            result_person(:similar_first_name, :similar_last_name, :common_relationship),
            result_person(:similar_first_name, :similar_last_name, :same_middle_name, :same_prefix, :blurb_keyword),
            result_person(:similar_first_name, :similar_last_name, :same_suffix, :blurb_keyword),
            result_person(:similar_first_name, :similar_last_name, :blurb_keyword),
            result_person(:similar_first_name, :similar_last_name, :same_middle_name, :same_prefix, :same_suffix),
            result_person(:similar_first_name, :similar_last_name)
          ]
        end

        it 'sorts array' do
          3.times do
            sorted = EntityMatcher::EvaluationResultSet.new(results.shuffle).to_a
            expect(sorted).to eql results
          end
        end
      end

      describe 'same last and similar last' do
        let(:results) do
          [
            result_person(:same_last_name, :blurb_keyword, :common_relationship),
            result_person(:same_last_name, :common_relationship),
            result_person(:same_last_name, :common_relationship),
            result_person(:same_last_name, :same_suffix, :blurb_keyword),
            result_person(:same_last_name, :blurb_keyword),
            result_person(:same_last_name, :same_middle_name, :same_prefix),
            result_person(:same_last_name, :same_suffix),
            result_person(:same_last_name, :same_suffix),
            result_person(:similar_last_name, :blurb_keyword),
            result_person(:similar_last_name, :same_middle_name, :same_prefix),
            result_person(:similar_last_name),
            result_person(:similar_last_name),
            result_person(:blurb_keyword, :same_first_name)
          ]
        end

        it 'sorts array' do
          3.times do
            sorted = EntityMatcher::EvaluationResultSet.new(results.shuffle).to_a
            expect(sorted).to eql results
          end
        end
      end

      describe 'from all categories' do
        let(:results) do
          [
            result_person(:same_first_name, :same_last_name, :same_middle_name, :common_relationship),
            result_person(:same_first_name, :same_last_name, :common_relationship),
            result_person(:same_first_name, :same_last_name, :blurb_keyword),
            result_person(:same_first_name, :same_last_name, :same_middle_name, :same_prefix, :same_suffix),
            result_person(:same_first_name, :similar_last_name, :common_relationship),
            result_person(:same_first_name, :similar_last_name, :blurb_keyword),
            result_person(:same_first_name, :similar_last_name),
            result_person(:similar_first_name, :similar_last_name, :blurb_keyword),
            result_person(:similar_first_name, :similar_last_name, :same_middle_name),
            result_person(:similar_first_name, :similar_last_name),
            result_person(:same_last_name, :same_suffix, :blurb_keyword),
            result_person(:same_last_name, :same_middle_name, :same_prefix),
            result_person(:similar_last_name, :blurb_keyword),
            result_person(:similar_last_name),
            result_person(:blurb_keyword, :common_relationship),
            result_person(:common_relationship),
            result_person(:blurb_keyword),
            result_person(:same_middle_name)
          ]
        end

        it 'sorts array' do
          3.times do
            sorted = EntityMatcher::EvaluationResultSet.new(results.shuffle).to_a
            expect(sorted).to eql results
          end
        end
      end
    end # end sorting people

    describe 'Sorting orgs' do
      let(:results) do
        [
          result_org(:same_name, :common_relationship, :blurb_keyword),
          result_org(:same_name, :similar_name, :blurb_keyword),
          result_org(:matches_alias, :similar_name, :blurb_keyword, :common_relationship),
          result_org(:same_name),
          result_org(:matches_alias, :similar_name),
          result_org(:similar_name, :common_relationship),
          result_org(:same_root, :blurb_keyword),
          result_org(:similar_root, :common_relationship),
          result_org(:similar_name),
          result_org(:same_root)
        ]
      end

      it 'sorts array' do
        3.times do
          sorted = EntityMatcher::EvaluationResultSet.new(results.shuffle).to_a
          expect(sorted).to eql results
        end
      end
    end # end sorting orgs
  end
end
