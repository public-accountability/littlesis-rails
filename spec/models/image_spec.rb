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

  describe 'soft_delete' do
    it 'changes is_deleted' do
      image = create(:image, entity: create(:org))
      expect { image.soft_delete }.to change { image.is_deleted }.to(true)
    end
  end

  describe 's3_url' do
    let(:image_url) { "https://assets.example.net/images/small/#{filename}" }
    specify { expect(build(:image, filename: filename).s3_url('small')).to eql image_url }
    specify { expect(build(:image, filename: filename).image_path('small')).to eql image_url }
  end

  describe 'Class Methods' do
    describe 's3_url' do
      specify do
        expect(Image.s3_url(filename, 'profile'))
          .to eql "https://assets.example.net/images/profile/#{filename}"
      end
    end

    describe 'image_path' do
      it 'returns asset host url for image' do
        expect(Image.image_path(filename, 'profile'))
          .to eql "https://assets.example.net/images/profile/#{filename}"
      end
    end
  end
end
