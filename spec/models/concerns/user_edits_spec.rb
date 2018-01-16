require 'rails_helper'

describe UserEdits do
  describe UserEdits::Edits do
    let!(:user) { create_basic_user }
    let(:entity) { build(:org) }
    let(:relationship) { build(:relationship) }

    let!(:versions) do
      [
        create(:entity_version, whodunnit: user.id, item_id: entity.id),
        create(:relationship_version, whodunnit: user.id, item_id: relationship.id)
      ].reverse
    end

    subject { UserEdits::Edits.new(user) }

    describe '#recent_edits' do
      it 'returns users recent edits for user' do
        expect(subject.recent_edits.length).to eql 2
      end
    end

    describe '#recent_edits_present' do
      before do
        rel_find = double('find')
        expect(rel_find).to receive(:find).with([relationship.id]).and_return([relationship])
        expect(Relationship).to receive(:unscoped).and_return(rel_find)
        entity_find = double('find')
        expect(entity_find).to receive(:find).with([entity.id]).and_return([entity])
        expect(Entity).to receive(:unscoped).and_return(entity_find)
      end

      it 'returns array of <UserEdit>s' do
        expect(subject.recent_edits_presenter.length).to eql 2
        expect(subject.recent_edits_presenter.first).to be_a UserEdits::Edits::UserEdit
        expect(subject.recent_edits_presenter.first.version).to eql versions.first
        expect(subject.recent_edits_presenter.first.resource).to eql relationship
        expect(subject.recent_edits_presenter.second.version).to eql versions.second
        expect(subject.recent_edits_presenter.second.resource).to eql entity
        expect(subject.recent_edits_presenter.second.action).to eql 'Update'
        expect(subject.recent_edits_presenter.second.time).to eql versions.second.created_at.strftime('%B %e, %Y%l%p')
      end

      describe '#record_lookup' do
        it 'generates a lookup hash' do
          expect(subject.send(:record_lookup))
            .to eq({
                     'Relationship' => { relationship.id => relationship },
                     'Entity' => { entity.id => entity }
                   })
        end
      end
    end
  end # UserEdits::Edits

  describe 'UserEdits.active_users' do

  end
end
