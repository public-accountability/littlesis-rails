require 'rails_helper'

describe ImageCropPresenter do
  describe 'image_dimensions' do
    let(:dimensions) { nil }
    let(:image) { instance_double('Image', :dimensions => dimensions) }
    let(:image_crop_presenter) do
      ImageCropPresenter.new(image).tap do |icp|
        icp.send(:instance_variable_set, :@type_for_crop, 'original')
      end
    end

    context 'when width is less than or equal to 900' do
      let(:dimensions) { Image::Dimensions.new(800, 500) }

      it 'does not scale the image' do
        expect(image_crop_presenter.image_dimensions)
          .to eq ImageCropPresenter::CropImageDimensions.new('original', 1.0, 800, 500)
      end
    end

    context 'when width is greater than 900' do
      let(:dimensions) { Image::Dimensions.new(1600, 1100) }

      it 'scales the image and sets the ratio accordingly' do
        expect(image_crop_presenter.image_dimensions)
          .to eq ImageCropPresenter::CropImageDimensions.new('original', 1.778, 900.0, 618.75)
      end
    end
  end

  describe 'type_for_crop' do
    let(:image) { instance_double('Image', :image_file => double(:exists? => false)) }

    it 'returns original if it exists' do
      allow(image).to receive(:image_file).with('original').and_return(double(:exists? => true))
      expect(ImageCropPresenter.new(image).type_for_crop).to eq 'original'
    end
    it 'returns large if large exists' do
      allow(image).to receive(:image_file).with('large').and_return(double(:exists? => true))
      expect(ImageCropPresenter.new(image).type_for_crop).to eq 'large'
    end
    it 'returns profile, otherwise' do
      expect(ImageCropPresenter.new(image).type_for_crop).to eq 'profile'
    end
  end
end
