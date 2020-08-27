describe DeletionRequests::EntitiesController, type: :controller do
  it { should use_before_action(:authenticate_user!) }
  it { should route(:get, '/deletion_requests/entities/1/review').to(action: :review, id: 1) }
  it { should route(:post, '/deletion_requests/entities/1/review').to(action: :commit_review, id: 1) }
  it { should route(:get, '/deletion_requests/entities/new').to(action: :new) }
  it { should route(:post, '/deletion_requests/entities').to(action: :create) }
end
