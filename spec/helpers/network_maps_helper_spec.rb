# frozen_string_literal: true

describe NetworkMapsHelper do
  describe 'network_map_feature_btn' do
    context 'when map is featured' do
      let(:map) { build(:network_map, is_featured: true) }

      it 'contains featured icon' do
        expect(helper.network_map_feature_btn(map)).to include 'class="star"'
      end
    end

    context 'when map is not featured' do
      let(:map) { build(:network_map, is_featured: false) }

      it 'contains not featured icon' do
        expect(helper.network_map_feature_btn(map)).to include 'class="not-star"'
      end
    end
  end
end
