# frozen_string_literal: true

describe EntityConnectionsQuery do
  let(:entity1) { create(:entity_person) }
  let(:entity2) { create(:entity_person) }
  let(:entity3) { create(:entity_person) }
  let(:entity4) { create(:entity_person) }

  before do
    create(:social_relationship, entity: entity1, related: entity2)
    create(:social_relationship, entity: entity1, related: entity3)
    create(:donation_relationship, entity: entity1, related: entity4)
  end

  it 'produces a paginatable result set' do
    result = EntityConnectionsQuery.new(entity1).category(Relationship::SOCIAL_CATEGORY).page(1).run
    expect(Api.send(:paginatable_collection?, result)).to be true
  end

  describe 'filtering by category' do
    let(:query) { EntityConnectionsQuery.new(entity1) }

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
end
