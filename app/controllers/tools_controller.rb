class ToolsController < ApplicationController

  SIMILAR_ENTITIES_PER_PAGE = 75

  class MergeModes
    SEARCH  = 'search'
    EXECUTE = 'execute'
    REQUEST = 'request'
    REVIEW  = 'review'
  end

  before_action :authenticate_user!
  before_action :set_entity, only: [:bulk_relationships]
  before_action :admins_only, only: [:merge_entities!]
  before_action :parse_merge_params, only: [:merge_entities]
  before_action :set_source_and_dest, only: [:merge_entities!]

  def bulk_relationships
  end

  # GET /tools/merge
  # possible params: mode, source, dest, query
  def merge_entities
  end

  # POST /tools/merge
  # do the merge
  def merge_entities!
    @source.merge_with(@dest)
    redirect_to @dest
  end

  private

  def parse_merge_params
    @source = Entity.find(params.require(:source).to_i)
    @merge_mode = params.require(:mode)
    case @merge_mode
    when MergeModes::SEARCH
      @query = params[:query]
      set_similar_entities
    when MergeModes::EXECUTE
      admins_only
      parse_merge_report_params
    when MergeModes::REQUEST
      parse_merge_report_params
    when MergeModes::REVIEW
      admins_only
      parse_merge_report_params
    end
  end

  def set_similar_entities
    if @query.present?
      similar_entities = Entity::Search.similar_entities(
        @source, query: @query, per_page: SIMILAR_ENTITIES_PER_PAGE
      )
    else
      similar_entities = @source.similar_entities(SIMILAR_ENTITIES_PER_PAGE)
    end
    @similar_entities = similar_entities.map(&Entity::Search::SIMILAR_ENTITIES_PRESENTER)
  end

  def parse_merge_report_params
    @dest = Entity.find(params[:dest].to_i)
    @entity_merger = EntityMerger.new(source: @source, dest: @dest).merge
  end

  def set_source_and_dest
    @source = Entity.find(params.require(:source).to_i)
    @dest = Entity.find(params.require(:dest).to_i)
  end

  def set_entity
    @entity = Entity.find(params.require(:entity_id))
  end
end
