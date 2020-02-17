# frozen_string_literal: true


describe OligrapherGraphDataImageFixer do
  let(:entity) { create(:entity_org) }
  let(:image) { create(:image, entity: entity, is_featured: true) }
  let(:nodes) { { entity.id.to_s => Oligrapher.legacy_entity_to_node(entity) } }

  def expect_http_to_receive_url(url)
    expect(HTTParty).to receive(:head)
                          .with(url, kind_of(Hash))
                          .and_return(
                            double(:code => 200,
                                   :headers => { 'content-length' => '1000' }))
  end

  describe 'no images need to be updated' do
    let(:nodes)  { { entity.id.to_s => Oligrapher.legacy_entity_to_node(entity) } }
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
    let(:nodes) do
      { entity.id.to_s => Oligrapher.legacy_entity_to_node(entity).deep_merge(display: { image: nil }) }
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
        .to eq entity.featured_image.image_url('profile')
    end
  end

  describe 'valid_url?' do
    it 'returns false if has no scheme' do
      expect(OligrapherGraphDataImageFixer.valid_image?('/some/path'))
        .to be false
    end

    it 'captures SocketError for no address' do
      msg = "Failed to open TCP connection to example:443 (getaddrinfo: No address associated with hostname"
      expect(HTTParty).to receive(:head).with('https://example.com', kind_of(Hash)).and_raise(SocketError.new(msg))

      expect(OligrapherGraphDataImageFixer.valid_image?('https://example.com')).to be false
    end

    it 'captures SocketError for not known name' do
      msg = "Failed to open TCP connection to example.com:443 (getaddrinfo: Name or service not known"
      expect(HTTParty).to receive(:head).with('https://example.com', kind_of(Hash)).and_raise(SocketError.new(msg))

      expect(OligrapherGraphDataImageFixer.valid_image?('https://example.com')).to be false
    end
  end
end
