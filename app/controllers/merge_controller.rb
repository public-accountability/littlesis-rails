# frozen_string_literal: true

class MergeController < ApplicationController
  SIMILAR_ENTITIES_PER_PAGE = 75

  module Modes
    SEARCH  = 'search'
    EXECUTE = 'execute'
    REQUEST = 'request'
    REVIEW  = 'review'
    ALL = [SEARCH, EXECUTE, REQUEST, REVIEW].freeze
  end

  before_action :authenticate_user!
  before_action :parse_merge_mode, only: [:merge, :merge!]
  before_action :check_permissions
  before_action :parse_get_params, only: [:merge]
  before_action :parse_post_params, only: [:merge!]
  before_action :parse_rendundant_review_params, only: [:redundant_merge_review]

  # GET /tools/merge
  # view the pages that help you create the merge
  # possible params: mode, source, dest, query
  def merge; end

  # POST /tools/merge
  # do the merge.
  def merge!
    case @merge_mode
    when Modes::EXECUTE
      @source.merge_with(@dest)
      redirect_to @dest
    when Modes::REVIEW
      @merge_request.send("#{@decision}_by!".to_sym, current_user)
      redirect_to @merge_request.dest, notice: "Merge request #{@decision}"
    when Modes::REQUEST
      mr = MergeRequest.create!(new_merge_request_params)
      # NotificationMailer.merge_request_email(mr).deliver_later
      redirect_to @source, notice: "Your request was sent to LittleSis admins"
    end
  end

  # GET /tools/redundant
  def redundant_merge_review
    check_ability :merge_entity
  end

  private

  def parse_merge_mode
    @merge_mode = Modes::ALL.dup.delete(params.require(:mode))
  end

  def check_permissions
    case @merge_mode
    when Modes::EXECUTE
      raise Exceptions::PermissionError unless current_user.role.include?(:merge_entity)
    when Modes::REVIEW
      raise Exceptions::PermissionError unless current_user.role.include?(:approve_request)
    end
  end

  # GET param parsers --v

  def parse_get_params
    send("parse_merge_#{@merge_mode}_params".to_sym)
  end

  def parse_merge_search_params
    set_source
    @query = params[:query]
    @similar_entities = resolve_similar_entities
                          .map(&Entity::Search::SIMILAR_ENTITIES_PRESENTER)
  end

  def parse_merge_execute_params
    set_source_and_dest
    set_entity_merger
  end

  def parse_merge_request_params
    parse_merge_execute_params
  end

  def parse_merge_review_params
    set_merge_request
    raise Exceptions::RedundantMergeReview unless @merge_request.pending?

    @source = @merge_request.source
    @dest = @merge_request.dest
    set_entity_merger
  rescue Exceptions::RedundantMergeReview
    redirect_to merge_redundant_path(request: @merge_request.id)
  end

  def parse_rendundant_review_params
    set_merge_request
  end

  # ^-- end GET param parsers

  def parse_post_params
    case @merge_mode
    when Modes::EXECUTE
      set_source_and_dest
    when Modes::REVIEW
      @merge_request = MergeRequest.find(params.require(:request).to_i)
      @decision = %w[approved denied].delete(params.require(:decision))
    when Modes::REQUEST
      set_source_and_dest
    end
  end

  def new_merge_request_params
    {
      user: current_user,
      source: @source,
      dest: @dest,
      justification: params.require('justification')
    }
  end

  # parser helpers

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

  def resolve_similar_entities
    return @source.similar_entities(SIMILAR_ENTITIES_PER_PAGE) if @query.blank?

    SimilarEntitiesService
      .new(@source, query: @query, per_page: SIMILAR_ENTITIES_PER_PAGE)
      .similar_entities
  end
end
