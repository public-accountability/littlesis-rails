describe DeletionRequests::ImagesController do
  it { is_expected.to route(:post, '/deletion_requests/images').to(action: :create) }
  it { is_expected.to route(:post, '/deletion_requests/images/123/review').to(action: :commit_review, id: 123) }
  it { is_expected.to route(:get, '/deletion_requests/images/123').to(action: :show, id: 123) }
end
