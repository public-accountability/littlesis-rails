require 'rails_helper'

describe RelationshipsDatatable do

  describe '#initialize' do
    let(:org) { build(:org) }
    let(:orgs) { [build(:org), build(:org)] }
    let(:links) { [build(:link, entity1_id: org.id), build(:link, entity1_id: org.id)] }
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

    it 'sets links' do
      expect(Link).to receive(:includes).once
                        .and_return(double(:where => double(:limit => [])))
      expect(RelationshipsDatatable.new(org).links).to eql []
    end

  end

  describe 'load_links' do
    let!(:entity) { create(:entity_person) }
    let!(:relationships) do
      Array.new(2) do
        create(:generic_relationship, entity: entity, related: create(:entity_person))
      end
    end
    subject { RelationshipsDatatable.new(entity) }

    it 'queries database for links' do
      expect(subject.links.to_set).to eql Link.where(entity1_id: entity.id).to_set
    end

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
