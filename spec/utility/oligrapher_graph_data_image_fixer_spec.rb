# frozen_string_literal: true

require 'rails_helper'

describe OligrapherGraphDataImageFixer do
  let(:entity) { create(:entity_org) }
  let(:image) { create(:image, entity: entity, is_featured: true) }
  let(:nodes)  { { entity.id.to_s => Oligrapher.entity_to_node(entity) } }
  

  def expect_http_to_receive_url(url)
    expect(HTTParty).to receive(:head)
                          .with(url, kind_of(Hash))
                          .and_return(double(code: 200))
  end

  describe 'no images need to be updated' do
    let(:nodes)  { { entity.id.to_s => Oligrapher.entity_to_node(entity) } }
    let(:graph_data) do
      OligrapherGraphData.new(id: 'abcdefg', nodes: nodes, edges: {}, captions: {})
    end

    before { entity; image; }

    it 'does not update the data' do
      expect_http_to_receive_url graph_data['nodes'][entity.id.to_s]['display']['image']
      fixer = OligrapherGraphDataImageFixer.new(graph_data)
      expect(fixer.changed?).to be false
    end
  end

  describe 'missing image url' do
    let(:nodes)  do
      { entity.id.to_s => Oligrapher.entity_to_node(entity).deep_merge(display: { image: nil })  }
    end

    let(:graph_data) do
      OligrapherGraphData.new(id: 'abcdefg', nodes: nodes, edges: {}, captions: {})
    end
    
    before { entity; image; }

    it 'updates the data' do
      fixer = OligrapherGraphDataImageFixer.new(graph_data)
      expect(fixer.changed?).to be true
    end

    it 'sets correct image url' do
      fixer = OligrapherGraphDataImageFixer.new(graph_data)
      expect(fixer.oligrapher_graph_data['nodes'][entity.id.to_s]['display']['image'])
        .to eq entity.featured_image.s3_url('profile')
    end
  end
end
