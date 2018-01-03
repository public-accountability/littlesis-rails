require 'rails_helper'

describe HomeHelper do
  let(:map_without_thumbnail) { build(:network_map, thumbnail: nil) }
  let(:map_with_thumbnail) { build(:network_map, thumbnail: '/image.png') }

  describe 'networkmap_image_path' do
    context 'thumbnail path is present' do
      subject { helper.networkmap_image_path(map_with_thumbnail) }
      it { is_expected.to eql '/image.png' }
    end

    context 'thumbnail is nil' do
      subject { helper.networkmap_image_path(map_without_thumbnail) }
      it { is_expected.to include '/assets/netmap-org' }
    end
  end
end
