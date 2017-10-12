require 'rails_helper'

describe Document, type: :model do
  it { should have_many(:references) }
  it { should validate_presence_of(:url) }
  it { should validate_presence_of(:url_hash) }
  it { should validate_length_of(:name).is_at_most(255) }
end
