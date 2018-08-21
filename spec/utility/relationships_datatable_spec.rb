require 'rails_helper'

describe RelationshipsDatatable do

  describe '#initialize' do
    let(:org) { build(:org) }
    let(:orgs) { [build(:org), build(:org)] }
    subject { RelationshipsDatatable.new(org) }

    it 'sets force_interlocks to be false by default' do
      expect(subject.instance_variable_get(:@force_interlocks)).to eql false
    end

    it 'wraps entities in an array' do
      expect(subject.entities).to eql [org]
      expect(RelationshipsDatatable.new(orgs).entities).to eql orgs
    end

    it 'sets @entity_ids' do
      expect(RelationshipsDatatable.new(orgs).instance_variable_get(:@entity_ids))
        .to eql orgs.map(&:id)
    end

    it 'sets links'

  end

  describe 'relationships' do
  end

  # why are these called list? and lists?
  describe "list?" do 
    it 'is true when initalized with more than one entity'
  end

  describe "lists?" do
    it 'is true when related id count is less than 1000'
  end

  describe "interlocks?" do
    it 'is true when num_links is less than 1000'
    it 'is true when force_interlocks is set'
  end
end
