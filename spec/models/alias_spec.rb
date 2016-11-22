require 'rails_helper'

describe Alias, type: :model  do
  it { should belong_to(:entity) }
end
