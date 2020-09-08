describe ImagesController do
  it { is_expected.to route(:get, '/images/123/crop').to(action: :crop, id: '123') }
  it { is_expected.to route(:post, '/images/123/crop').to(action: :crop, id: '123') }
  it { is_expected.to route(:post, '/images/123/update').to(action: :update, id: '123') }
end
