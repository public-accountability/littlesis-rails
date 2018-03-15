require 'rails_helper'

describe EntityMatcher, :sphinx do

  def result_maker(*args)
    EntityMatcher::EvaluationResult::Person.new.tap do |er|
      args.each { |x| er.send("#{x}=", true) }
    end
  end

  describe 'Search' do
    # creates a sample set of 5 people: 2 Vibes, 2 Traverses, and 1 Chum of chance
    before(:all) do
      setup_sphinx 'entity_core' do
        @chum = EntitySpecHelpers.chums(num: 1).first
        @chum_alias = { first: Faker::Name.first_name, last: Faker::Name.last_name }
        @chum.aliases.create!(name: [@chum_alias[:first], @chum_alias[:last]].join(' '))
        @chum.person.update!(name_nick: 'Balloonist')
        @entities = EntitySpecHelpers.bad_vibes(num: 2) + EntitySpecHelpers.traverses(num: 2) + Array.wrap(@chum)
      end
    end

    after(:all) { teardown_sphinx { delete_entity_tables } }

    describe 'searching for a chum' do
      def self.expect_to_find_the_chum
        specify do
          expect(subject.length).to eql 1
          expect(subject.first).to eql @chum
        end
      end

      describe 'finds by alias' do
        subject { EntityMatcher::Search.by_name(@chum_alias[:last]) }
        expect_to_find_the_chum
      end

      describe 'finds by nickname' do
        subject { EntityMatcher::Search.by_name('Balloonist') }
        expect_to_find_the_chum
      end
    end

    describe 'searching using a person' do
      specify do
        expect(EntityMatcher::Search.by_person(@entities.first).count).to eql 1
      end
    end

    describe 'last name search' do
      it 'finds 2 traverses' do
        expect(EntityMatcher::Search.by_name('traverse').count).to eql 2
      end

      it 'finds 2 traverses if other names are also included in the search' do
        expect(EntityMatcher::Search.by_name('traverse', 'randomname').count).to eql 2
      end

      it 'finds 2 vibes' do
        expect(EntityMatcher::Search.by_name('vibe').count).to eql 2
      end

      it 'finds vibes and traverses at once' do
        expect(EntityMatcher::Search.by_name('traverse', 'vibe').count).to eql 4
      end
    end
  end

  describe 'Query' do
    describe 'Org' do
      context 'provided string name' do
        let(:name) { '' }
        subject { EntityMatcher::Query::Org.new(name).to_s }
        context 'simple name' do
          let(:name) { "simplecorp" }
          it { is_expected.to eql "(*simplecorp*)" }
        end

        context 'simple name with suffix' do
          let(:name) { "SimpleCorp llc" }
          it { is_expected.to eql "(*simplecorp* *llc*) | (simplecorp)" }
        end

        context 'long name with essential words' do
          let(:name) { "American Green Tomatoes Corp" }
          it do
            is_expected.to eql "(*american* *green* *tomatoes* *corp*) | (american green tomatoes) | (green tomatoes)"
          end
        end
      end
    end

    describe 'Person' do
      subject { EntityMatcher::Query::Person.new(entity).to_s }
      let(:names) { [] }
      let(:entity) { EntitySpecHelpers.person(*names) }
      let(:person) { entity.person }

      context 'person has first and last name only' do
        it { is_expected.to eql "(#{entity.name})" }
      end

      context 'person has first, last, and middle names' do
        let(:names) { ['middle'] }
        it { is_expected.to eql "(#{entity.name}) | (#{person.name_first} #{person.name_last})" }
      end

      context 'person has first, last, middle, and suffix' do
        let(:names) { %w[middle suffix] }
        let(:person) { entity.person }
        it do
          is_expected.to eql "(#{entity.name}) | (#{person.name_first} #{person.name_last}) | (#{person.name_first} #{person.name_last} #{person.name_suffix})"
        end
      end

      context 'person has first, last, middle, prefix and suffix' do
        let(:names) { %w[middle prefix suffix] }

        it do
          is_expected
            .to eql "(#{entity.name}) | (#{person.name_first} #{person.name_last}) | (#{person.name_first} #{person.name_last} #{person.name_suffix}) | (#{person.name_prefix} #{person.name_last})"
        end
      end
    end

    describe 'Names' do
      context 'single name' do
        subject { EntityMatcher::Query::Names.new('Thoreau').to_s }
        it { is_expected.to eql "(*Thoreau*)" }
      end
      context 'two names' do
        subject { EntityMatcher::Query::Names.new('bob', 'alice').to_s }
        it { is_expected.to eql "(*bob*) | (*alice*)" }
      end

      context 'two names in an array' do
        subject { EntityMatcher::Query::Names.new(%w[bob alice]).to_s }
        it { is_expected.to eql "(*bob*) | (*alice*)" }
      end
    end
  end

  describe 'TestCase' do
    describe EntityMatcher::TestCase::Org do
      subject { EntityMatcher::TestCase::Org }
      let(:org) { build(:org, :with_org_name) }

      it 'sets @entity' do
        expect(subject.new(org).entity).to be_a Entity
        expect(subject.new('corp').entity).to be nil
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

      it 'sets name when provided hash' do
        expect(subject.new('name_last' => 'Last', 'name_first' => 'First').name)
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

      it 'raises error if called with an hashing missing a last name' do
        expect { subject.new(first_name: 'xyz') }
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

      # EntityMatcher::TestCase::Person.new(
      #     build(:person, person: build(:a_person, fields))
      #   )
      context 'same last names' do
        let(:test_case) do
          EntityMatcher::TestCase::Person.new('jane doe')
        end

        let(:match) do
          generate_test_case name_last: 'Doe'
        end

        specify do
          expect(subject.new(test_case, match).result.same_last_name)
            .to eql true

          expect(subject.new(test_case, match).result.same_first_name)
            .to eql false
        end
      end

      context 'same first name' do
        let(:first_name) { Faker::Name.first_name }
        let(:test_case) do
          EntityMatcher::TestCase::Person.new "#{first_name} #{Faker::Name.unique.last_name}"
        end

        let(:match) do
          generate_test_case name_first: first_name, name_last: Faker::Name.unique.last_name
        end

        specify do
          expect(subject.new(test_case, match).result.same_first_name)
            .to eql true

          expect(subject.new(test_case, match).result.same_last_name)
            .to eql false
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
          expect(subject.new(test_case, match).result.same_first_name).to eql true
          expect(subject.new(test_case, match).result.same_last_name).to eql true
          expect(subject.new(test_case, match).result.same_middle_name).to eql true
        end
      end

      context 'mismatched suffix ' do
        let(:test_case) do
          EntityMatcher::TestCase::Person.new "#{Faker::Name.first_name} #{Faker::Name.last_name}"
        end

        let(:match) do
          generate_test_case name_first: Faker::Name.first_name, name_suffix: 'JR'
        end

        specify do
          expect(subject.new(test_case, match).result.blurb_keyword).to be_nil
          expect(subject.new(test_case, match).result.same_suffix).to be_nil
          expect(subject.new(test_case, match).result.mismatched_suffix).to eql true
        end
      end

      context 'similar first names' do
        let(:test_case) do
          EntityMatcher::TestCase::Person.new "Cindi #{Faker::Name.unique.last_name}"
        end

        let(:match) do
          generate_test_case name_first: 'cindy', name_last: Faker::Name.unique.last_name
        end

        specify do
          expect(subject.new(test_case, match).result.similar_last_name).to be false
          expect(subject.new(test_case, match).result.similar_first_name).to eql true
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
          expect(subject.new(test_case, match).result.common_relationship).to eql false
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
            expect(subject.new(test_case, match).result.common_relationship).to eql false
            expect(subject.new(test_case, match).result.blurb_keyword).to eql true
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
            expect(subject.new(test_case, match).result.common_relationship).to eql false
            expect(subject.new(test_case, match).result.blurb_keyword).to eql true
          end
        end
      end
    end # end EntityMatcher::Evaluation::Person

    describe EntityMatcher::EvaluationResult::Person do
      describe '#equal_first_last?' do
        context 'same names' do
          subject { result_maker(:same_last_name, :same_first_name) }
          specify { expect(subject.same_first_last?).to eql true }
        end

        context 'different names' do
          before do
            subject.same_last_name = false
            subject.same_first_name = true
          end
          specify { expect(subject.same_first_last?).to eql false }
        end

        describe 'same_middle_prefix_suffix_count' do
          context 'zero' do
            specify { expect(subject.same_middle_prefix_suffix_count).to eql 0 }
          end

          context 'two' do
            subject { result_maker(:same_prefix, :same_suffix) }
            before  { subject.same_middle_name = false }
            specify { expect(subject.same_middle_prefix_suffix_count).to eql 2 }
          end
        end
      end
      
      describe 'Sorting' do
        describe 'same first_and_last' do
          let(:results) do
            [
              result_maker(:same_first_name, :same_last_name, :same_middle_name, :same_prefix, :same_suffix),
              result_maker(:same_first_name, :same_last_name, :same_middle_name, :same_prefix),
              result_maker(:same_first_name, :same_last_name, :same_middle_name, :common_relationship),
              result_maker(:same_first_name, :same_last_name, :same_middle_name),
              result_maker(:same_first_name, :same_last_name, :common_relationship),
              result_maker(:same_first_name, :same_last_name, :blurb_keyword)
#              result_maker(:same_first_name, :similar_last_name, :same_suffix)
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
              result_maker(:same_first_name, :similar_last_name, :same_middle_name, :same_prefix, :same_suffix),
              result_maker(:same_first_name, :similar_last_name, :same_middle_name, :same_prefix, :common_relationship),
              result_maker(:same_first_name, :similar_last_name, :same_middle_name, :same_prefix, :blurb_keyword),
              result_maker(:same_first_name, :similar_last_name, :same_suffix, :blurb_keyword),
              result_maker(:same_first_name, :similar_last_name, :common_relationship),
              result_maker(:same_first_name, :similar_last_name, :blurb_keyword),
              result_maker(:same_first_name, :similar_last_name)
            ]
          end
          it 'sorts array' do
            3.times do
              sorted = EntityMatcher::EvaluationResultSet.new(results.shuffle).to_a
              expect(sorted).to eql results
            end
          end
        end

        describe 'similar first and similar last' do
          let(:results) do
            [
              result_maker(:same_first_name, :same_last_name),
              result_maker(:same_first_name, :similar_last_name),
              result_maker(:similar_first_name, :similar_last_name, :same_middle_name, :same_prefix, :same_suffix),
              result_maker(:similar_first_name, :similar_last_name, :same_middle_name, :same_prefix, :common_relationship),
              result_maker(:similar_first_name, :similar_last_name, :same_middle_name, :same_prefix, :blurb_keyword),
              result_maker(:similar_first_name, :similar_last_name, :same_suffix, :blurb_keyword),
              result_maker(:similar_first_name, :similar_last_name, :common_relationship),
              result_maker(:similar_first_name, :similar_last_name, :blurb_keyword),
              result_maker(:similar_first_name, :similar_last_name)
            ]
          end
          it 'sorts array' do
            3.times do
              sorted = EntityMatcher::EvaluationResultSet.new(results.shuffle).to_a
              expect(sorted).to eql results
            end
          end
        end
      end
      
    end
  end
end

