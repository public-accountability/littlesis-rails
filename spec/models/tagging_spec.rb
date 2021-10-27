describe Tagging, type: :model do
  let(:user) { create_basic_user }
  let(:org) { create(:entity_org) }
  let(:tag) { create(:tag) }
  let(:list) { create(:list) }

  it { is_expected.to have_db_column(:tag_id) }
  it { is_expected.to have_db_column(:tagable_class) }
  it { is_expected.to have_db_column(:tagable_id) }
  it { is_expected.to have_db_column(:last_user_id) }

  it { is_expected.to validate_presence_of(:tag_id) }
  it { is_expected.to validate_presence_of(:tagable_class) }
  it { is_expected.to validate_presence_of(:tagable_id) }

  it { is_expected.to belong_to(:tag) }
  it { is_expected.to belong_to(:last_user) }

  describe 'update entity timestamp' do
    it 'updates entity timestamp after creating a tagging' do
      org.update_column(:updated_at, 1.day.ago)
      expect { org.add_tag(tag.id) }.to change { org.reload.updated_at }
    end

    it 'sets last_user_id to be the system\'s default user' do
      org.update_columns(updated_at: 1.day.ago, last_user_id: user.id)
      expect { org.add_tag(tag.id) }
        .to change { org.reload.last_user_id }.to(User.system_user_id)
    end
  end

  with_versioning do
    context 'when an has been tagged entity' do
      before { org.add_tag(tag.id) }

      it 'the tagging\'s version records entity id' do
        expect(org.taggings.first.versions.first.entity1_id).to eql org.id
      end
    end

    context 'when a list has been tagged' do
      before { list.add_tag(tag.id) }

      it 'the tagging\'s version does not record any metadata for entity1_id' do
        expect(list.taggings.first.versions.first.entity1_id).to be nil
      end
    end
  end
end
