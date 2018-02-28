require 'rails_helper'

describe EntityMatcher, :sphinx do
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
        subject { EntityMatcher.search_by_name(@chum_alias[:last]) }
        expect_to_find_the_chum
      end

      describe 'finds by nickname' do
        subject { EntityMatcher.search_by_name('Balloonist') }
        expect_to_find_the_chum
      end
    end

    describe 'searching using a person' do
      specify do
        expect(EntityMatcher.search_by_person(@entities.first).count).to eql 1
      end
    end

    describe 'last name search' do
      it 'finds 2 traverses' do
        expect(EntityMatcher.search_by_name('traverse').count).to eql 2
      end

      it 'finds 2 traverses if other names are also included in the search' do
        expect(EntityMatcher.search_by_name('traverse', 'randomname').count).to eql 2
      end

      it 'finds 2 vibes' do
        expect(EntityMatcher.search_by_name('vibe').count).to eql 2
      end

      it 'finds vibes and traverses at once' do
        expect(EntityMatcher.search_by_name('traverse', 'vibe').count).to eql 4
      end
    end
  end

  describe 'Query' do
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

  describe 'Matcher' do
    describe 'initialize using delegator pattern' do
      let(:org) { build(:org) }
      specify { expect(EntityMatcher::Matcher.new(org).__getobj__).to eql org }
    end
  end
end
