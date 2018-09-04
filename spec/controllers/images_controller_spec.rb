require 'rails_helper'

describe ImagesController do
  it { is_expected.to route(:get, '/images/123/crop').to(action: :crop, id: '123') }
  it { is_expected.to route(:post, '/images/123/crop_remote').to(action: :crop_remote, id: '123') }
  it { is_expected.to route(:post, '/images/123/request_deletion').to(action: :request_deletion, id: '123') }
  it { is_expected.to route(:post, '/images/approve_deletion/123').to(action: :approve_deletion, image_deletion_request_id: '123') }
  it { is_expected.to route(:post, '/images/deny_deletion/123').to(action: :deny_deletion, image_deletion_request_id: '123') }
  it { is_expected.to route(:get, '/images/deletion_request/123').to(action: :deletion_request, image_deletion_request_id: '123') }
end
