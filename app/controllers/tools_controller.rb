class ToolsController < ApplicationController
  SIMILAR_ENTITIES_PER_PAGE = 75

  before_action :authenticate_user!
  before_action :set_entity, only: [:bulk_relationships]
  before_action -> { check_permission 'merger' }, only: [:merge_entities, :merge_entities!]
  before_action :parse_merge_params, only: [:merge_entities]
  before_action :set_source_and_dest, only: [:merge_entities!]

  def bulk_relationships
  end

  # GET /tools/merge
  # There are 3 combinatations of params this accepts:
  # - source
  # - source and query
  # - source and dest
  def merge_entities
    set_similar_entities if @merge_mode == :search
  end

  # POST /tools/merge
  # do the merge
  def merge_entities!
    @source.merge_with(@dest)
    redirect_to @dest
  end

  private

  def set_similar_entities
    if @query.present?
      similar_entities = Entity::Search.similar_entities(@source, query: @query, per_page: SIMILAR_ENTITIES_PER_PAGE)
    else
      similar_entities = @source.similar_entities(SIMILAR_ENTITIES_PER_PAGE)
    end
    @similar_entities = similar_entities.map(&Entity::Search::SIMILAR_ENTITIES_PRESENTER)
  end

  def parse_merge_params
    @source = Entity.find(params.require(:source).to_i)
    if params[:dest].present?
      @merge_mode = :merge
      @dest = Entity.find(params[:dest].to_i)
      @entity_merger = EntityMerger.new(source: @source, dest: @dest).merge
    else
      @merge_mode = :search
      @query = params[:query]
    end
  end

  def set_source_and_dest
    @source = Entity.find(params.require(:source).to_i)
    @dest = Entity.find(params.require(:dest).to_i)
  end

  def set_entity
    @entity = Entity.find(params.require(:entity_id))
  end
end
