require 'rails_helper'

describe S3 do
  describe 'url' do
    let(:path) { '/a/b/c.png' }
    specify do
      expect(S3.url(path)).to eql 'https://s3.amazonaws.com/littlesis-dev/a/b/c.png'
    end
  end
end
