require 'rails_helper'

describe ImageFile do
  let(:filename) { Image.random_filename }

  describe 'initalize' do
    let(:filename) { 'bfb4af0697205cb0e108785afa861f8f.jpg' }

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

  describe 'pathname' do
    let(:image_file) { ImageFile.new(filename: filename, type: :small) }

    specify { expect(image_file.pathname).to be_a Pathname }
  end

  describe '#exists?' do
    let(:image_data) do
      Base64.decode64("iVBORw0KGgoAAAANSUhEUgAAAAEAAAABAQMAAAAl21bKAAAAA1BMVEUAAACn\nej3aAAAAAXRSTlMAQObYZgAAAApJREFUCNdjYAAAAAIAAeIhvDMAAAAASUVO\nRK5CYII=\n")
    end
    let(:image_file) { ImageFile.new(filename: filename, type: :small) }

    context 'when the file does not exists' do
      specify { expect(image_file.exists?).to eq false }
    end

    context 'when the file exists' do
      before do
        FileUtils.mkdir_p(image_file.pathname.dirname.to_s)
        File.write(image_file.path, 'wb') { |f| f.write(image_data) }
      end

      specify { expect(image_file.exists?).to be true }
    end

    context 'when the file exists' do
      before do
        FileUtils.mkdir_p(image_file.pathname.dirname.to_s)
        File.write(image_file.path, 'wb') { |f| f.write(image_data) }
      end

      specify { expect(image_file.exists?).to be true }
    end

    context 'when the file exists but is empty' do
      before do
        FileUtils.mkdir_p(image_file.pathname.dirname.to_s)
        FileUtils.touch(image_file.path)
      end

      specify { expect(image_file.exists?).to be false }
    end
  end
end
