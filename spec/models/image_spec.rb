require 'rails_helper'

describe Image, type: :model do
  let(:filename) { "#{Digest::MD5.hexdigest(Time.current.to_i.to_s)}.png" }

  describe 'validations, associations, and constants' do
    it { is_expected.to validate_presence_of(:entity_id) }
    it { is_expected.to validate_presence_of(:filename) }
    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to belong_to(:entity) }
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:address) }
    specify { expect(Image::IMAGE_SIZES).to be_a Hash }
  end

  describe 'Soft Delete / Destroy' do
    let(:entity) { create(:entity_org) }
    let(:image) { create(:image, entity: entity, is_featured: true) }
    let(:not_featured) { create(:image, entity: entity, is_featured: false) }

    describe 'soft_delete' do
      before { image }
      it 'changes is_deleted' do
        expect { image.soft_delete }.to change { image.is_deleted }.to(true)
      end
    end

    describe 'destroy' do
      before do
        image
        not_featured
      end

      it 'changes is_deleted' do
        expect { image.destroy }.to change { image.is_deleted }.to(true)
      end

      it 'destorying image also unfeatures the image' do
        expect { image.destroy }
          .to change { not_featured.reload.is_featured }
                .from(false).to(true)
      end

    end
  end

  describe 'feature/unfeature' do
    let!(:entity) { create(:entity_person) }
    let!(:featured_image) { create(:image, entity: entity, is_featured: true) }
    let!(:image) { create(:image, entity: entity, is_featured: false) }

    describe '#feature' do
      it 'sets is_featured to true' do
        expect { image.feature }
          .to change { image.reload.is_featured }.from(false).to(true)
      end

      it 'removes featured status from other images' do
        expect { image.feature }
          .to change { featured_image.reload.is_featured }.from(true).to(false)
      end
    end

    describe '#unfeature' do
      it 'sets is_featured to false' do
        expect { featured_image.unfeature }
          .to change { featured_image.reload.is_featured }.from(true).to(false)
      end

      it 'features another image' do
        expect { featured_image.unfeature }
          .to change { image.reload.is_featured }.from(false).to(true)
      end
    end
  end

  describe 's3_url' do
    let(:image_url) { "https://images.example.net/images/small/#{filename}" }
    specify { expect(build(:image, filename: filename).s3_url('small')).to eql image_url }
    specify { expect(build(:image, filename: filename).image_path('small')).to eql image_url }
  end

  describe 'Class Methods' do
    describe 's3_url' do
      specify do
        expect(Image.s3_url(filename, 'profile'))
          .to eql "https://images.example.net/images/profile/#{filename}"
      end
    end

    describe 'image_path' do
      it 'returns asset host url for image' do
        expect(Image.image_path(filename, 'profile'))
          .to eql "https://images.example.net/images/profile/#{filename}"
      end
    end

    describe 'random_filename' do
      it 'returns random file name with provided extension' do
        filename = Image.random_filename('svg')
        expect(filename.split('.')[0].length).to eql 32
        expect(filename.split('.')[1]).to eql 'svg'
      end

      it 'returns random file name with default extension' do
        filename = Image.random_filename
        expect(filename.split('.')[0].length).to eql 32
        expect(filename.split('.')[1]).to eql 'jpg'
      end

      it 'can accept file names with "."' do
        filename = Image.random_filename('.png')
        expect(filename.length).to eql 36
        expect(filename[-5]).not_to eql '.'
      end
    end

    describe 'file_ext_from' do
      it 'returns extension from url' do
        expect(Image.file_ext_from('https://example.com/example.png'))
          .to eql 'png'
      end

      it 'retrieves information from head if no extension found' do
        url = 'https://example.com/example_image'
        head = double('HTTParty::Response head double')
        expect(head).to receive(:success?).and_return true
        expect(head).to receive(:[]).with('content-type').and_return('image/jpg')
        expect(HTTParty).to receive(:head).with(url).and_return(head)
        expect(Image.file_ext_from(url)).to eql 'jpg'
      end

      it 'raises error if there is an invalid format' do
        url = 'https://example.com/example_image'
        head = double('HTTParty::Response head double')
        expect(head).to receive(:success?).and_return true
        expect(head).to receive(:[]).with('content-type').and_return('audio/mpeg3')
        expect(HTTParty).to receive(:head).with(url).and_return(head)
        expect { Image.file_ext_from(url) }
          .to raise_error { Image::InvalidFileExtensionError }
      end

      it 'raises error if request is a faliure' do
        url = 'https://example.com/example_image'
        head = double('HTTParty::Response head double')
        expect(head).to receive(:success?).and_return false
        expect(HTTParty).to receive(:head).with(url).and_return(head)

        expect { Image.file_ext_from(url) }
          .to raise_error { Image::RemoteImageRequestFailure }
      end
    end
  end # end Class Methods
end
