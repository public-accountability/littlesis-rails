class RelationshipsController < ApplicationController
  before_action :set_relationship
 
  def show
  end

  def set_relationship
    @relationship = Relationship.find(params[:id])
  end

end
