require 'rails_helper'

describe ImageFile do
  let(:filename) { Image.random_filename }
  let(:image_data) do
    Base64.decode64("iVBORw0KGgoAAAANSUhEUgAAAAEAAAABAQMAAAAl21bKAAAAA1BMVEUAAACn\nej3aAAAAAXRSTlMAQObYZgAAAApJREFUCNdjYAAAAAIAAeIhvDMAAAAASUVO\nRK5CYII=\n")
  end

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

  describe 'write' do
    let(:image_file) { ImageFile.new(filename: filename, type: :small) }
    let(:test_png_path) { Rails.root.join('spec', 'testdata', '1x1.png').to_s }
    let(:mini_magick_img) { MiniMagick::Image.open(test_png_path) }

    before do
      # ensure tmp folder exists
      FileUtils.mkdir_p(image_file.pathname.dirname.dirname.to_s)
    end

    after do
      FileUtils.rm_rf(image_file.pathname.dirname.dirname)
    end

    it 'raises error if not called with MiniMagick::Image' do
      expect { image_file.write('no soy una imagen') }.to raise_error(TypeError)
    end

    it 'creates prefix dir if it does not exists' do
      expect { image_file.write(mini_magick_img) }
        .to change { image_file.pathname.dirname.exist? }.from(false).to(true)
    end

    it 'continues if creates prefix dir exists' do
      FileUtils.mkdir_p(image_file.pathname.dirname)
      expect { image_file.write(mini_magick_img) }.not_to raise_error
    end

    it 'writes image to file' do
      expect { image_file.write(mini_magick_img) }
        .to change { image_file.exists? }.from(false).to(true)
    end

    it 'writes content correctly' do
      image_file.write(mini_magick_img)
      expect(FileUtils.compare_file(image_file.path, test_png_path)).to be true
    end
  end
end
