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

      describe 'recenter_edits_presenter' do
        subject { UserEdits::Edits.new(user).recent_edits_presenter }

        it 'returns array of <UserEdit>s' do
          expect(subject.length).to eql 2
          expect(subject.first).to be_a UserEdits::Edits::UserEdit
          expect(subject.first.version).to eql versions.first
          expect(subject.first.resource).to eql relationship
          expect(subject.second.version).to eql versions.second
          expect(subject.second.resource).to eql entity
          expect(subject.second.action).to eql 'Update'
          expect(subject.second.time).to eql(versions.second.created_at.strftime('%B %e, %Y%l%p'))
        end
      end

      describe '#record_lookup' do
        let(:record_lookup) do
          {
            'Relationship' => { relationship.id => relationship },
            'Entity' => { entity.id => entity }
          }
        end

        specify { expect(subject.send(:record_lookup)).to eq(record_lookup) }
      end
    end
  end # UserEdits::Edits

  describe 'User.active_users' do
    before(:all) { PaperTrail::Version.delete_all }

    let(:user_one) { create_really_basic_user }
    let(:user_two) { create_really_basic_user }
    let!(:update_event) { create(:entity_version, whodunnit: user_one.id.to_s, event: 'update') }
    let!(:destory_event) { create(:entity_version, whodunnit: user_one.id.to_s, event: 'destroy') }
    let!(:soft_delete_event) { create(:relationship_version, whodunnit: user_one.id.to_s, event: 'soft_delete') }
    let!(:create_event) { create(:entity_version, whodunnit: user_two.id.to_s, event: 'create') }

    subject { User.active_users }

    it 'returns an array of ActiveUsers, correctly sorted' do
      expect(subject.length). to eql 2
      expect(subject.first).to be_a UserEdits::ActiveUser
      expect(subject.first.user).to eql user_one
      expect(subject.second.user).to eql user_two
    end

    it 'ActiveUser contains correct edits count' do
      expect(subject.first.edits).to eql 3
      expect(subject.first.create_count).to be_zero
      expect(subject.first.update_count).to eql 1
      expect(subject.first.delete_count).to eql 2

      expect(subject.second.edits).to eql 1
      expect(subject.second.create_count).to eql 1
      expect(subject.second.update_count).to be_zero
      expect(subject.second.delete_count).to be_zero
    end
  end
end
