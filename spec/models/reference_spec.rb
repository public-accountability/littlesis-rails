describe Reference do
  it { is_expected.to belong_to(:referenceable) }
  it { is_expected.to belong_to(:document) }
  it { is_expected.to validate_presence_of(:referenceable_type) }
  it { is_expected.to validate_presence_of(:referenceable_id) }
  it { is_expected.to validate_presence_of(:document_id) }
end
