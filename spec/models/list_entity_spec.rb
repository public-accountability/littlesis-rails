require 'rails_helper'

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
          PaperTrail.whodunnit(user.id.to_s) do
            ListEntity.create!(entity_id: entity.id, list_id: list.id)
          end
        end
      end

      context 'creating a list' do
        it 'creates a version' do
          expect(&create_list_entity)
            .to change { PaperTrail::Version.count }.by(1)
        end

        it 'sets entity1_id correctly' do
          create_list_entity.call
          expect(ListEntity.last.versions.first.entity1_id).to eql entity.id
        end
      end
    end
  end
end
