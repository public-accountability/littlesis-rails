# frozen_string_literal: true

class Api::RelationshipsController < Api::ApiController
  before_action :set_relationship

  def show
    render json: @relationship.as_api_json
  end

  def set_relationship
    @relationship = Relationship.unscoped.find(params[:id])
    raise Exceptions::ModelIsDeletedError if @relationship.is_deleted?
  end
end
