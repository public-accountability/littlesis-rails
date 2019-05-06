# frozen_string_literal: true


describe NetworkMapsHelper do
  describe 'oligrapher_js_tags' do
    specify do
      expect(helper.oligrapher_js_tags)
        .to eq '<script src="/js/oligrapher/oligrapher-0.0.1.js"></script><script src="/js/oligrapher/oligrapher_littlesis_bridge-0.0.1.js"></script>'
    end
  end

  describe 'network_map_feature_btn' do
    context 'when map is featured' do
      let(:map) { build(:network_map, is_featured: true) }

      it 'contains featured icon' do
        expect(helper.network_map_feature_btn(map)).to include 'class="featured-map-star"'
      end
    end

    context 'when map is not featured' do
      let(:map) { build(:network_map, is_featured: false) }

      it 'contains not featured icon' do
        expect(helper.network_map_feature_btn(map)).to include 'class="not-featured-map-star"'
      end
    end
  end
end
