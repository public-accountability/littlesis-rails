require 'rails_helper'

describe EntityMatcher do
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
  end

  describe 'Matcher' do
    describe 'initialize using delegator pattern' do
      let(:org) { build(:org) }
      specify { expect(EntityMatcher::Matcher.new(org).__getobj__).to eql org }
    end
  end
end
