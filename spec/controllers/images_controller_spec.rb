require 'rails_helper'

describe ImagesController do
  it { is_expected.to route(:get, '/images/123/crop').to(action: :crop, id: '123') }
  it { is_expected.to route(:get, '/images/123/crop_remote').to(action: :crop, id: '123') }
end
