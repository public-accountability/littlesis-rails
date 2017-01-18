class ToolsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_entity

  def bulk_relationships
  end

  private

  def set_entity
    @entity = Entity.find(params.require(:entity_id))
  end
end
