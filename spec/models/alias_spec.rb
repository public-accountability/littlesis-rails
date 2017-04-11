require 'rails_helper'

describe Alias, type: :model  do
  it { should belong_to(:entity) }
  it { should validate_length_of(:name).is_at_most(200) }
  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:entity_id) }
end
