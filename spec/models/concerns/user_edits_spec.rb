# rubocop:disable RSpec/NamedSubject, RSpec/BeforeAfterAll, RSpec/ExpectInHook

describe UserEdits do
  describe UserEdits::Edits do
    let(:ids) do
      {
        'entity' => Faker::Number.unique.number(digits: 5).to_i,
        'relationship' => Faker::Number.unique.number(digits: 5).to_i,
        'entity1_id' => Faker::Number.unique.number(digits: 5).to_i,
        'entity2_id' => Faker::Number.unique.number(digits: 5).to_i
      }
    end

    let(:user) { create_basic_user }

    let(:relationship) do
      build :relationship, id: ids['relationship']
    end

    let(:entity) do
      build :org, id: ids['entity']
    end

    let(:entity_version) do
      create(:entity_version, whodunnit: user.id, item_id: ids['entity']).tap do |v|
        v.update_column :created_at, 1.year.ago
      end
    end

    let(:relationship_version) do
      create(:relationship_version,
             whodunnit: user.id,
             item_id: ids['relationship'],
             entity1_id: ids['entity1_id'],
             entity2_id: ids['entity2_id'])
    end

    before do
      entity_version
      relationship_version
    end

    xdescribe '#edited_entities_ids' do
      subject { UserEdits::Edits.new(user) }

      it 'returns array of all recently edited entities' do
        expect(subject.edited_entities_ids)
          .to eq ids.values_at('entity1_id', 'entity2_id', 'entity')
      end
    end

    describe '#edited_entities' do
      let(:entities) do
        Array.new(3) { create(:entity_person) }
      end

      let(:relationship) do
        create(:generic_relationship, entity: entities[0], related: entities[1])
      end

      let(:ids) do
        { 'entity' => entities[0].id,
          'entity1_id' => entities[1].id,
          'entity2_id' => entities[2].id,
          'relationship' => relationship.id }
      end

      it 'returns relation of all recently edited entities' do
        edited_entities = UserEdits::Edits.new(user).edited_entities
        expect(edited_entities.total_count).to eq 3
      end
    end

    describe '#recent_edits' do
      subject { UserEdits::Edits.new(user) }

      it "returns a user's recent edits" do
        expect(subject.recent_edits.length).to eq 2
      end
    end

    describe '#recent_edits_present' do
      before do
        rel_find = double('find')
        expect(rel_find).to receive(:find).with([ids['relationship']]).and_return([relationship])
        expect(Relationship).to receive(:unscoped).and_return(rel_find)
        entity_find = double('find')
        expect(entity_find).to receive(:find).with([entity.id]).and_return([entity])
        expect(Entity).to receive(:unscoped).and_return(entity_find)
      end

      describe 'recenter_edits_presenter' do
        subject { UserEdits::Edits.new(user).recent_edits_presenter }

        it 'returns array of <UserEdit>s' do
          expect(subject.length).to eq 2
          expect(subject.first).to be_a UserEdits::Edits::UserEdit
          expect(subject.first.version).to eql relationship_version
          expect(subject.first.resource).to eql relationship
          expect(subject.second.version).to eql entity_version
          expect(subject.second.resource).to eql entity
          expect(subject.second.action).to eql 'Update'
          expect(subject.second.time).to eql(entity_version.created_at.strftime('%B %e, %Y%l%p'))
        end
      end

      describe '#record_lookup' do
        subject { UserEdits::Edits.new(user) }

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

  describe 'Active users' do
    before(:all) { PaperTrail::Version.delete_all }

    let(:user_one) { create_really_basic_user }
    let(:user_two) { create_really_basic_user }

    before do
      create(:entity_version, whodunnit: user_one.id.to_s, event: 'create')
      create(:entity_version, whodunnit: user_one.id.to_s, event: 'update')
      create(:entity_version, whodunnit: user_one.id.to_s, event: 'destroy')
      create(:relationship_version, whodunnit: user_one.id.to_s, event: 'soft_delete')

      create(:entity_version, whodunnit: user_two.id.to_s, event: 'create')
      create(:relationship_version, whodunnit: user_two.id.to_s, event: 'create')
    end

    describe 'User.active_users' do
      subject { User.active_users }

      it 'returns an array of ActiveUsers, correctly sorted' do
        expect(subject.length).to eq 2
        expect(subject.first).to be_a UserEdits::ActiveUser
        expect(subject.first.user).to eq user_two
        expect(subject.second.user).to eq user_one

        expect(subject.first.version.except('id'))
          .to eq('whodunnit' => user_two.id.to_s,
                 'edits' => 2,
                 'entity_create_count' => 1,
                 'relationship_create_count' => 1,
                 'create_count' => 2,
                 'update_count' => 0,
                 'delete_count' => 0)

        expect(subject.second.version.except('id'))
          .to eq('whodunnit' => user_one.id.to_s,
                 'edits' => 4,
                 'entity_create_count' => 1,
                 'relationship_create_count' => 0,
                 'create_count' => 1,
                 'update_count' => 1,
                 'delete_count' => 2)

        expect(User.uniq_active_users).to eq 2
      end
    end
  end
end

# rubocop:enable RSpec/NamedSubject, RSpec/BeforeAfterAll, RSpec/ExpectInHook
