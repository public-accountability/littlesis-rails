# frozen_string_literal: true

describe EntityConnectionsQuery do
  let(:entity1) { create(:entity_person) }
  let(:entity2) { create(:entity_person) }
  let(:entity3) { create(:entity_person) }
  let(:entity4) { create(:entity_person) }
  let(:relationship1) { create(:social_relationship, entity: entity1, related: entity2) }
  let(:relationship2) { create(:social_relationship, entity: entity1, related: entity3) }
  let(:relationship3) { create(:donation_relationship, entity: entity1, related: entity4) }

  let(:query) { EntityConnectionsQuery.new(entity1) }

  before { relationship1; relationship2; relationship3; }

  it 'produces a paginatable result set' do
    result = EntityConnectionsQuery.new(entity1).category(Relationship::SOCIAL_CATEGORY).page(1).run
    expect(Api.send(:paginatable_collection?, result)).to be true
  end

  it 'includes fields "relationship_id" and "relationship_category_id"' do
    result = EntityConnectionsQuery.new(entity1).category(Relationship::DONATION_CATEGORY).page(1).run
    expect(result.first.relationship_id).to eq relationship3.id
    expect(result.first.relationship_category_id).to eq 5
  end

  describe 'filtering by category' do
    specify do
      expect(
        query.category(Relationship::SOCIAL_CATEGORY).page(1).run.size
      ).to eq 2
    end

    specify do
      expect(
        query.category(Relationship::SOCIAL_CATEGORY).page(2).run.size
      ).to eq 0
    end

    specify do
      expect(
        query.category(Relationship::DONATION_CATEGORY).page(1).run.size
      ).to eq 1
    end
  end

  describe 'excluding entities by id' do
    specify do
      expect(EntityConnectionsQuery.new(entity1).page(1).run.size).to eq 3
      expect(EntityConnectionsQuery.new(entity1).exclude([1_000_000]).page(1).run.size).to eq 3
      expect(EntityConnectionsQuery.new(entity1).exclude([entity2.id]).page(1).run.size).to eq 2
      expect(EntityConnectionsQuery.new(entity1).exclude([entity2.id, entity3.id]).page(1).run.size).to eq 1
    end

    specify do
      expect(
        query.exclude(entity3.id).category(Relationship::SOCIAL_CATEGORY).page(1).run.size
      ).to eq 1

    end

    specify do
      expect(
        query.category(Relationship::SOCIAL_CATEGORY).exclude([entity2.id, entity3.id]).page(1).run.size
      ).to eq 0
    end
  end

  describe 'accepts category ids as strings' do
    specify do
      expect(
        query.category(Relationship::DONATION_CATEGORY.to_s).page(1).run.size
      ).to eq 1
    end
  end
end
