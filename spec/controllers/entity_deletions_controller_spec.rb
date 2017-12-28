require 'rails_helper'

describe DeletionRequestsController, type: :controller do
  it { should use_before_action(:authenticate_user!) }
  it { should use_before_action(:set_entity) }
  it { should route(:get, '/deletion_requests/1/review').to(action: :review, id: 1) }
  it { should route(:get, review_deletion_request_path(1)).to(action: :review, id: 1) }
end
