require 'rails_helper'

describe ApiToken, type: :model do
  it { should belong_to(:user) }
  it { should validate_presence_of(:user_id) }

  describe 'Create' do
    it 'creates with secure random token' do
      user = build(:user_with_id)
      ApiToken.create!(user: user)
      expect(ApiToken.last.token.length).to be > 16
      expect(ApiToken.last.user_id).to eql user.id
    end

    it 'can be created via user association' do
      user = create(:user, sf_guard_user: create(:sf_guard_user))
      expect { user.create_api_token }.to change { ApiToken.count }.by(1)
    end
  end
end
