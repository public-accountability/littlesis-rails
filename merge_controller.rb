class MergeController < ApplicationController
  SIMILAR_ENTITIES_PER_PAGE = 75

  class MergeModes
    SEARCH  = 'search'.freeze
    EXECUTE = 'execute'.freeze
    REQUEST = 'request'.freeze
    REVIEW  = 'review'.freeze
    ALL = [SEARCH, EXECUTE, REQUEST, REVIEW].freeze
  end

  before_action :authenticate_user!
  before_action :admins_only, only: [:merge_entities!]
  before_action :parse_merge_mode, only: [:merge_entities, :merge_entities!]
  before_action :parse_merge_get_params, only: [:merge_entities]
  before_action :parse_merge_post_params, only: [:merge_entities!]
  before_action :parse_rendundant_review_params, only: [:redundant_merge_review]

  # GET /merge
  # possible params: mode, query, source, dest, request
  def merge; end

  # POST /tools/merge
  # do the merge.freeze
  def merge!
    case @merge_mode
    when MergeModes::EXECUTE
      @source.merge_with(@dest)
      redirect_to @dest
    when MergeModes::REVIEW
      @merge_request.send("#{@decision}_by!".to_sym, current_user)
      redirect_to @merge_request.source
    end
  end

  # GET /merge/redundant
  def redundant_merge_review; end

  private

  # merge GET param parsers --v

  def parse_merge_get_params
    send("parse_merge_#{@merge_mode}_params".to_sym)
  end

  def parse_merge_mode
    @merge_mode = MergeModes::ALL.dup.delete(params.require(:mode))
  end

  def parse_merge_search_params
    set_source
    @query = params[:query]
    @similar_entities = resolve_similar_entities
                          .map(&Entity::Search::SIMILAR_ENTITIES_PRESENTER)
  end

  def resolve_similar_entities
    return @source.similar_entities(SIMILAR_ENTITIES_PER_PAGE) unless @query.present?
    Entity::Search.similar_entities(@source,
                                    query: @query,
                                    per_page: SIMILAR_ENTITIES_PER_PAGE)
  end

  def parse_merge_execute_params
    admins_only
    set_source_and_dest
    set_entity_merger
  end

  def parse_merge_request_params
    set_source_and_dest
    set_entity_merger
  end

  def parse_merge_review_params
    admins_only
    set_merge_request
    raise Exceptions::RedundantMergeReview unless @merge_request.pending?

    @source = @merge_request.source
    @dest = @merge_request.dest
    set_entity_merger
  rescue Exceptions::RedundantMergeReview
    redirect_to merge_redundant_path(request: @merge_request.id)
  end

  def parse_rendundant_review_params
    admins_only
    set_merge_request
  end

  # ^-- end merge GET param parsers

  def parse_merge_post_params
    admins_only
    case @merge_mode
    when MergeModes::EXECUTE
      set_source_and_dest
    when MergeModes::REVIEW
      @merge_request = MergeRequest.find(params.require(:request).to_i)
      @decision = %w[approved denied].delete(params.require(:decision))
    end
  end

  # helpers

  def set_entity_merger
    @entity_merger = EntityMerger.new(source: @source, dest: @dest).merge
  end

  def set_source
    @source = Entity.find(params.require(:source).to_i)
  end

  def set_source_and_dest
    set_source
    @dest = Entity.find(params.require(:dest).to_i)
  end

  def set_merge_request
    @merge_request = MergeRequest.find(params.require(:request).to_i)
  end
end
