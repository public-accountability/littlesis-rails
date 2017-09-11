require 'rails_helper'

describe Tagging, type: :model do

  it { should have_db_column(:tag_id) }
  it { should have_db_column(:tagable_class) }
  it { should have_db_column(:tagable_id) }
  it { should validate_presence_of(:tag_id) }
  it { should validate_presence_of(:tagable_class) }
  it { should validate_presence_of(:tagable_id) }

  it { should belong_to(:tag) }

  before(:all) do
    @sf_user = create(:sf_user)
  end

  describe 'update entity timestamp' do
    let(:org) { create(:org) }
    let(:tag) { create(:tag) }

    it 'updates entity timestamp after creating a tagging' do
      org.update_column(:updated_at, 1.day.ago)
      expect { org.tag(tag.id) }.to change { org.reload.updated_at }
    end

    it 'sets last_user_id to be the system\'s default user' do
      org.update_columns(updated_at: 1.day.ago, last_user_id: @sf_user.id)
      expect { org.tag(tag.id) }
        .to change { org.reload.last_user_id }.to(Tagging::DEFAULT_LAST_USER_ID)
    end
  end
end
