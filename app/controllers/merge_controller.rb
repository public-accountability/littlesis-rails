# frozen_string_literal: true

class MergeController < ApplicationController
  PER_PAGE = 75

  module Modes
    SEARCH  = 'search'
    EXECUTE = 'execute'
    REQUEST = 'request'
    REVIEW  = 'review'
    ALL = [SEARCH, EXECUTE, REQUEST, REVIEW].freeze
  end

  before_action :authenticate_user!, :current_user_can_edit?
  helper_method :merge_mode



  # GET /entities/merge
  #
  # Search: Search page similar entities
  #   /entities/merge?mode=search&source=ENTITY_ID
  # Search: Get data for similar entities (used in js client)
  #   /entities/merge?mode=search&source=ENTITY_ID&query=example.json
  # Request: Page to create Merge Request
  #   /entities/merge?mode=request&source=ID1&dest=ID2
  # Review: Page to view merge request (Report)
  #   /entities/merge?mode=review&srequest=ID
  # Execute: Page to perform merge request (Report)
  #
  def merge
    case merge_mode
    when Modes::SEARCH
      set_source
      @query = params[:query].presence

      respond_to do |format|
        format.json { render json:  get_similar_entities }
        format.html
      end
    when Modes::REQUEST, Modes::EXECUTE
      # see partial merge/merge_report
      set_source
      set_dest
      set_entity_merger
    when Modes::REVIEW
      @merge_request = MergeRequest.find(params.require(:request).to_i)

      if @merge_request.pending?
        @source = @merge_request.source
        @dest = @merge_request.dest
        set_entity_merger
      else
        redirect_to merge_redundant_entities_path(request: @merge_request.id)
      end
    end
  end

  # POST /entities/merge
  #   when mode=execute performs the merge
  #   when mode=review marks request as approved or denied. if approved, perform the merge.
  #   when mode=request create a new MergeRequest
  def merge!
    case merge_mode

    # Creating a new Merge Request. Any editor can do this
    when Modes::REQUEST
      set_source
      set_dest
      MergeRequest.create!(user: current_user,
                           source: @source,
                           dest: @dest,
                           justification: params.require('justification'))
      # NotificationMailer.merge_request_email(mr).deliver_later
      redirect_to @source, notice: "Your request was sent to LittleSis admins. Thank you."

    #  Directly perform a merge. Collaborators can do this
    when Modes::EXECUTE
      set_source
      set_dest
      @source.merge_with(@dest)
      redirect_to @dest
    # Approve or deny a request. Admins can do this.
    # If approved, also performs the merge request
    when Modes::REVIEW
      @merge_request = MergeRequest.find(params.require(:request).to_i)
      @decision = %w[approved denied].delete(params.require(:decision))
      @merge_request.send("#{@decision}_by!".to_sym, current_user)
      redirect_to @merge_request.dest, notice: "Merge request #{@decision}"
    end
  end

  # GET /entities/redundant
  def redundant_merge_review
    check_ability(:merge_entity)
    set_merge_request
  end

  private

  def merge_mode
    @merge_mode ||= params.require(:mode).tap do |mode|
      raise TypeError unless Modes::ALL.include?(mode)

      if mode == 'execute' && current_user.role.exclude?(:merge_entity)
        raise Exceptions::PermissionError,
              "User #{current_user.id} is not allowed to merge entities"
      end

      if mode == 'review' && current_user.role.exclude?(:approve_request)
        raise Exceptions::PermissionError,
              "User #{current_user.id} is not allowed to approve requests"
      end
    end
  end

  # Param helpers

  # search mode
  # def parse_merge_search_params
  #   set_source
  #   @query = params[:query]
  # end

  # # execute mode
  # def parse_merge_execute_params
  #   set_source
  #   set_dest
  #   set_entity_merger
  # end

  # # request mode
  # def parse_merge_request_params
  #   set_source
  #   set_dest
  #   set_entity_merger
  # end

  # review mode
      def parse_merge_review_params

      end

      # parser helpers

      def set_entity_merger
        @entity_merger = EntityMerger.new(source: @source, dest: @dest).merge
      end

      def set_source
        @source = Entity.find(params.require(:source).to_i)
      end

      def set_dest
        @dest = Entity.find(params.require(:dest).to_i)
      end

      def set_merge_request
        @merge_request = MergeRequest.find(params.require(:request).to_i)
      end

      def get_similar_entities
        SimilarEntitiesService
          .new(@source, query: @query, per_page: PER_PAGE)
          .similar_entities
          .map(&Entity::Search::SIMILAR_ENTITIES_PRESENTER)
      end
end
