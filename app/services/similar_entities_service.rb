# frozen_string_literal: true

class SimilarEntitiesService
  DEFAULT_SIMILAR_ENTITIES_PER_PAGE = 5
  SIMILAR_ENTITY_FIELD_WEIGHTS = { name: 15, aliases: 10, blurb: 3 }.freeze

  attr_reader :entity
  attr_accessor :query, :per_page

  def initialize(entity_or_id, query: nil, per_page: nil)
    @entity = Entity.entity_for(entity_or_id)
    @query = query
    @per_page = per_page || DEFAULT_SIMILAR_ENTITIES_PER_PAGE
  end

  def similar_entities
    Entity.search search_query, search_options

  # If a sphinx encounters an error, we will ignore it and return an empty array
  rescue ThinkingSphinx::ConnectionError => err
    Rails.logger.error "Cannot connect to Sphinx :( \n #{err.message}"
    return []
  rescue ThinkingSphinx::SphinxError => err
    msg = "A Sphinx Error occured while attempting to get similar entities for entity #{@entity.id}:\n #{err.message}"
    Rails.logger.error msg
    return []
  end

  private

  def search_options
    { :with => { primary_ext: @entity.primary_ext, is_deleted: false },
      :without => { sphinx_internal_id: @entity.id },
      :per_page => @per_page,
      :ranker => :sph04,
      :sql => { :include => :extension_records },
      :select => '*, weight() + (link_count * 10) AS link_weight',
      :order => 'link_weight DESC',
      :field_weights => SIMILAR_ENTITY_FIELD_WEIGHTS,
      # needed in order to for the error rescues to work
      # see: https://github.com/pat/thinking-sphinx/issues/180
      :populate => true }
  end

  def search_query
    q = @query.present? ? LsSearch.escape(@query) : @entity.generate_search_terms
    "@!summary #{q}"
  end
end
