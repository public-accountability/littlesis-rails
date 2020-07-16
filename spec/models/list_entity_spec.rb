describe ListEntity do
  it { is_expected.to belong_to(:list) }
  it { is_expected.to belong_to(:entity) }

  describe 'versioning' do
    with_versioning do
      let!(:user) { create_really_basic_user }
      let!(:list) { create(:list) }
      let!(:entity) { create(:entity_org) }
      let(:create_list_entity) do
        proc do
          PaperTrail.request(whodunnit: user.id.to_s) do
            ListEntity.create!(entity_id: entity.id, list_id: list.id)
          end
        end
      end

      context 'when creating a list' do
        it 'creates a version' do
          expect(&create_list_entity)
            .to change { PaperTrail::Version.count }.by(1)
        end

        it 'sets entity1_id correctly' do
          create_list_entity.call
          expect(ListEntity.last.versions.first.entity1_id).to eql entity.id
        end

        it 'puts list_id in other_id column' do
          create_list_entity.call
          expect(ListEntity.last.versions.first.other_id).to eql list.id
        end
      end
    end
  end

  describe 'list counts' do
    let!(:some_list) { create(:list) }
    let!(:entity) { create(:entity_org) }
    let!(:list_entity) { create(:list_entity, list: some_list, entity: entity) }

    context 'when adding an entity to a list' do
      it "updates the list's entity_count" do
        expect { create(:list_entity, list: some_list, entity: entity) }
          .to change(some_list, :entity_count).by(1)
      end
    end

    context 'when removing an entity from a list' do
      it "updates the list's entity_count" do
        expect { list_entity.destroy }
          .to change(some_list, :entity_count).by(-1)
      end
    end
  end
end
