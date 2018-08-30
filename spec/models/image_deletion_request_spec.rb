require 'rails_helper'

describe ImageDeletionRequest, type: :model do
  it { is_expected.to validate_presence_of(:source_id) }

  it 'correctly subclasses UserRequest' do
    image_deletion_request = ImageDeletionRequest.new
    expect(image_deletion_request).to be_a UserRequest
    expect(image_deletion_request).to be_a ImageDeletionRequest
    expect(image_deletion_request.type).to eql 'ImageDeletionRequest'
  end

end
