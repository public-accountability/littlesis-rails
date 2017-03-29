require 'rails_helper'

describe PublicCompany do
  it { should belong_to(:entity) }
  it { should validate_length_of(:ticker).is_at_most(10) }
end
