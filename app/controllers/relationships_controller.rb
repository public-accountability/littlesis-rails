class RelationshipsController < ApplicationController
  before_action :set_relationship, only: [:show]
 
  def show
  end

  # Creates a new Relationship and a Reference
  # Returns status code 201 if sucuessful or a json of errors with status code 400
  def create
    @relationship = Relationship.new(relationship_params)
    @reference = Reference.new(reference_params)
    
    if @relationship.valid? and @reference.validate_before_create.empty?
      @relationship.save!
      @reference.assign_attributes(object_id: @relationship.id, object_model: "Relationship")
      @reference.save
      render json: {'relationship_id' => @relationship.id}, status: :created
    else
      errors = {
        relationship: @relationship.errors.to_h,
        reference: @reference.validate_before_create
      }
      render json: errors, status: :bad_request
    end
  end
  
  private

  def set_relationship
    @relationship = Relationship.find(params[:id])
  end
  
  def relationship_params
    params.require(:relationship).permit(:entity1_id, :entity2_id, :category_id)
  end

  def reference_params
    params.require(:reference).permit(:name, :source, :source_detail, :publication_date, :ref_type)
  end

end
