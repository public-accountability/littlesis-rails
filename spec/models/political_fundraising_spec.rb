require 'rails_helper'

describe PoliticalFundraising, type: :model do
  it { should belong_to(:entity) }
end
