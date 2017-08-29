require 'rails_helper'

describe UserPermission, type: :model do

  # fields
  it { should have_db_column(:user_id) }
  it { should have_db_column(:resource_type) }
  it { should have_db_column(:access_rules) }

  # associations
  it { should respond_to(:user) }

  # validation
  it { should validate_presence_of(:user_id) }
  it { should validate_presence_of(:resource_type) }
  it { should_not validate_presence_of(:access_rules) }
  
end
