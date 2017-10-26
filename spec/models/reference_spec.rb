require 'rails_helper'

describe Reference do
  it { should belong_to(:referenceable) }
  it { should belong_to(:document) }
  it { should validate_presence_of(:referenceable_type) }
  it { should validate_presence_of(:referenceable_id) }
  it { should validate_presence_of(:document_id) }
end
