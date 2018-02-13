require 'rails_helper'

describe Tagging, type: :model do
  it { should have_db_column(:tag_id) }
  it { should have_db_column(:tagable_class) }
  it { should have_db_column(:tagable_id) }
  it { should have_db_column(:last_user_id) }

  it { should validate_presence_of(:tag_id) }
  it { should validate_presence_of(:tagable_class) }
  it { should validate_presence_of(:tagable_id) }

  it { should belong_to(:tag) }
  it { should belong_to(:last_user) }

  before(:all) { @sf_user = create(:sf_user) }
  after(:all) { @sf_user.delete }

  let(:org) { create(:org) }
  let(:tag) { create(:tag) }
  let(:list) { create(:list) }

  describe 'update entity timestamp' do
    it 'updates entity timestamp after creating a tagging' do
      org.update_column(:updated_at, 1.day.ago)
      expect { org.add_tag(tag.id) }.to change { org.reload.updated_at }
    end

    it 'sets last_user_id to be the system\'s default user' do
      org.update_columns(updated_at: 1.day.ago, last_user_id: @sf_user.id)
      expect { org.add_tag(tag.id) }
        .to change { org.reload.last_user_id }.to(APP_CONFIG['system_user_id'])
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
