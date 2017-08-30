require 'rails_helper'

describe UserPermission, type: :model do

  # fields
  it { should have_db_column(:user_id) }
  it { should have_db_column(:resource_type) }
  it { should have_db_column(:access_rules) }

  # associations
  it { should belong_to(:user) }


  # validation
  it { should validate_presence_of(:user_id) }
  it { should validate_presence_of(:resource_type) }
  it { should_not validate_presence_of(:access_rules) }

  let(:user_permission) do
    UserPermission.create(user_id: 1,
                          resource_type: 'Tagging',
                          access_rules: '{ "tag_ids": [1]}')
  end
  let(:user_permission_without_rules) do
    UserPermission.create(user_id: 1,
                          resource_type: 'List',
                          access_rules: nil)
  end
  
  it 'returns access rules as hash with indifferent access' do
    expect(user_permission.access_rules).to eq ({ 'tag_ids' => [1] })
    expect(user_permission.access_rules[:tag_ids]).to eq [1]
    expect(user_permission_without_rules.access_rules).to be_nil
  end

  it 'returns resource type as a class name constant' do
    expect(user_permission.resource_type).to eq Tagging
  end
end
