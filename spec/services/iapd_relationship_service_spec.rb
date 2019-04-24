require "rails_helper"

# rubocop:disable RSpec/MultipleExpectations, RSpec/MessageSpies

describe IapdRelationshipService do
  describe 'initalize' do
    let(:advisor) { instance_double('IapdDatum') }
    let(:owner) { instance_double('IapdDatum') }
    let(:relationship) { instance_double('Relationship') }

    context 'when owner is matched' do
      before { allow(owner).to receive(:matched?).and_return(true) }

      it 'sets result properly when relationship exists' do
        expect(IapdRelationshipService).to receive(:find_relationship).and_return(relationship)
        expect(IapdRelationshipService).not_to receive(:create_relationship)
        service = IapdRelationshipService.new(advisor: advisor, owner: owner)
        expect(service.result).to eq :relationship_exists
        expect(service.relationship).to eq relationship
      end

      it 'sets result and creates relationship when relationship does not exists' do
        expect(IapdRelationshipService).to receive(:find_relationship).and_return(nil)
        expect(IapdRelationshipService).to receive(:create_relationship).and_return(relationship)
        service = IapdRelationshipService.new(advisor: advisor, owner: owner)
        expect(service.result).to eq :relationship_created
        expect(service.relationship).to eq relationship
      end

      it 'does not create a relationship when dry_run' do
        expect(IapdRelationshipService).to receive(:find_relationship).and_return(nil)
        expect(IapdRelationshipService).not_to receive(:create_relationship)
        service = IapdRelationshipService.new(advisor: advisor, owner: owner, dry_run: true)
        expect(service.dry_run).to be true
        expect(service.result).to eq :relationship_created
      end

      it 'freezes the object' do
        expect(IapdRelationshipService).to receive(:find_relationship).and_return(relationship)
        expect(IapdRelationshipService.new(advisor: advisor, owner: owner)).to be_frozen
      end
    end

    context 'when owner is not matched' do
      before { allow(owner).to receive(:matched?).and_return(false) }

      it 'adds owner to matching queue' do
        expect(owner).to receive(:add_to_matching_queue).once
        IapdRelationshipService.new(advisor: advisor, owner: owner, dry_run: true)
      end

      it 'sets result to "owner_not_matched"' do
        allow(owner).to receive(:add_to_matching_queue)
        expect(IapdRelationshipService.new(advisor: advisor, owner: owner, dry_run: true).result)
          .to eq :owner_not_matched
      end
    end
  end

  describe 'Class methods' do
    describe 'create_relationship'
    describe 'find_relationships'
    describe 'create_relationships_for'
  end
end

# rubocop:enable RSpec/MultipleExpectations, RSpec/MessageSpies
