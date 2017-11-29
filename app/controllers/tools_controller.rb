class ToolsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_entity, only: [:bulk_relationships]
  before_action -> { check_permission('bulker') }, only: [:merge_entities]
  before_action :parse_merge_params, only: [:merge_entities]

  def bulk_relationships
  end

  # GET /tools/merge
  # There are 3 combinatations of params this accepts:
  # - source
  # - source and query
  # - source and dest
  def merge_entities
  end

  # POST /tools/merge
  # do the merge
  def merge_entities!
  end

  private

  def parse_merge_params
    @source = Entity.find(params.require(:source).to_i)
    if params[:dest].present?
      @merge_mode = :merge
    else
      @merge_mode = :search
    end
  end

  def set_entity
    @entity = Entity.find(params.require(:entity_id))
  end
end
