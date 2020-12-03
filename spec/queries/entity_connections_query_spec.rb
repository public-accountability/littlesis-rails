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

  it 'includes fields "relationship_id" and "relationship_category_id"' do
    query.category_id = Relationship::DONATION_CATEGORY
    query.order = :updated
    query.run

    expect(query.results.first.connected_relationship_ids).to eq "#{relationship3.id}"
    expect(query.results.first.connected_category_id).to eq 5
  end

  describe 'filtering by category' do
    specify do
      query.category_id = Relationship::SOCIAL_CATEGORY
      expect(query.run.size).to eq 2
    end

    specify do
      query.category_id = Relationship::SOCIAL_CATEGORY
      query.page = 2
      expect(query.run.size).to eq 0
    end

    specify do
      query.category_id = Relationship::DONATION_CATEGORY
      query.order = :amount
      expect(query.run.size).to eq 1
    end
  end

  describe 'excluding entities by id' do
    specify do
      query.excluded_ids = [100_000_000]
      expect(query.run.size).to eq 3
    end

    specify do
      query.excluded_ids = [entity2.id]
      expect(query.run.size).to eq 2
    end

    specify do
      query.excluded_ids = [entity2.id, entity3.id]
      expect(query.run.size).to eq 1
    end

    specify do
      query.excluded_ids = [entity3.id]
      query.category_id = Relationship::SOCIAL_CATEGORY
      expect(query.run.size).to eq 1
    end

    specify do
      query.excluded_ids = [entity2.id, entity3.id]
      query.category_id = Relationship::SOCIAL_CATEGORY
      expect(query.run.size).to eq 0
    end
  end

  describe 'accepts category ids as strings' do
    specify do
      query.category_id = Relationship::DONATION_CATEGORY.to_s
      expect(query.run.size).to eq 1
    end
  end
end
