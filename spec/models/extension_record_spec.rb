require 'rails_helper'

describe ExtensionRecord, type: :model do
  it { should belong_to(:entity) }
  it { should belong_to(:extension_definition) }
end
