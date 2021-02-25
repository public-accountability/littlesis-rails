describe ImageDeletionRequest, type: :model do
  it { is_expected.to validate_presence_of(:source_id) }

  it 'correctly subclasses UserRequest' do
    image_deletion_request = ImageDeletionRequest.new
    expect(image_deletion_request).to be_a UserRequest
    expect(image_deletion_request).to be_a ImageDeletionRequest
    expect(image_deletion_request.type).to eql 'ImageDeletionRequest'
  end

  describe 'creating and approving' do
    let(:image) { create(:image, entity: create(:entity_org)) }
    let(:request) do
      ImageDeletionRequest.create!(image: image,
                                   user: create_really_basic_user,
                                   justification: 'incorrect photo')
    end
    let(:admin) { create_admin_user }

    # it 'emails a notification after the request is submitted' do
    #   expect(NotificationMailer)
    #     .to receive(:image_deletion_request_email).once
    #           .with(kind_of(ImageDeletionRequest))
    #           .and_return(double(deliver_later: nil))
    #   request
    # end

    it 'approve! deletes the image' do
      expect { request.approved_by!(admin) }
        .to change { image.reload.is_deleted }
              .from(false).to(true)
    end
  end
end
