# frozen_string_literal: true

class OligrapherGraphDataImageFixer
  def self.updated_graph_data(oligrapher_graph_data)
    new(oligrapher_graph_data).oligrapher_graph_data
  end

  attr_reader :original_graph_data, :graph_data

  def initialize(graph_data)
    TypeCheck.check graph_data, OligrapherGraphData

    @original_graph_data = graph_data.to_h
    @graph_data = @original_graph_data.deep_dup
    update_images
    freeze
  end

  def oligrapher_graph_data
    OligrapherGraphData.new(@graph_data)
  end

  def update_images
    @graph_data['nodes'].each_pair do |id, node_data|
      next unless entity_lookup.key?(id.to_i) # If the node is is for a LittleSis entity

      image_url = node_data.dig('display', 'image')

      next if image_url.present? && valid_image?(image_url)

      node_data['display']['image'] = new_image_path(id)
    end
  end

  def new_image_path(id)
    entity_lookup.fetch(id.to_i).featured_image&.s3_url('profile').presence || ''
  end

  def valid_image?(url)
    url = "https:#{url}" if url.slice(0, 2) == '//'
    return false if URI(url).scheme.nil?

    Rails.logger.debug "[OligrapherGraphDataImageFixer] Checking url: #{url}"

    HTTParty
      .head(url, follow_redirects: true, maintain_method_across_redirects: true)
      .code
      .eql?(200)
  end

  def entity_lookup
    return @_entity_lookup if defined?(@_entity_lookup)

    entity_ids = @graph_data['nodes'].keys.select { |k| k.match?(/^\d+$/) }.map(&:to_i).uniq

    @_entity_lookup ||= Entity.lookup_table_for(entity_ids, ignore: true)
  end

  def changed?
    @original_graph_data != @graph_data
  end
end
