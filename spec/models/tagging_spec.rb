require 'rails_helper'

describe Tagging, type: :model do
  it { should have_db_column(:tag_id) }
  it { should have_db_column(:tagable_class) }
  it { should have_db_column(:tagable_id) }
  it { should validate_presence_of(:tag_id) }
  it { should validate_presence_of(:tagable_class) }
  it { should validate_presence_of(:tagable_id) }
end
