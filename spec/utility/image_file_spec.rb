require 'rails_helper'

describe ImageFile do
  let(:filename) { 'bfb4af0697205cb0e108785afa861f8f.jpg' }

  describe 'initalize' do
    it 'errors if type is inavlid' do
      expect { ImageFile.new(filename: filename, type: 'very_very_small') }
        .to raise_error(Exceptions::LittleSisError)
    end

    it 'sets filename and type' do
      image_file = ImageFile.new(filename: filename, type: :profile)
      expect(image_file.filename).to eq filename
      expect(image_file.type).to eq 'profile'
    end

    it 'correctly sets path' do
      image_file = ImageFile.new(filename: filename, type: 'profile')
      expect(image_file.path).to eq 'tmp/profile/bf/bfb4af0697205cb0e108785afa861f8f.jpg'
    end
  end
end
