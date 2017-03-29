class RelationshipsController < ApplicationController
  before_action :set_relationship, only: [:show, :edit, :update, :reverse_direction]
  before_action :authenticate_user!, except: [:show]

  def show
  end

  # GET /relationships/:id/edit
  def edit
    @selected_ref = params[:new_ref].present? ? @relationship.references.last.id : nil
  end

  # PATCH /relationships/:id
  def update
    if existing_reference_params['reference_id'].blank? && existing_reference_params['just_cleaning_up'].blank?
      # If user has not checked the 'just cleaning up' or selected an existing reference
      # then a  new reference must be created
      @reference = Reference.new(reference_params)
      # if not valid: re-render the edit page with the reference error
      return render :edit unless @reference.validate_before_create.empty?
      # if the reference is valid assign the other attribute required
      @reference.assign_attributes(object_id: @relationship.id, object_model: "Relationship")
    end
    if @relationship.update_attributes prepare_update_params(update_params)
      @reference.save unless @reference.nil? # save the reference
      update_entity_last_user
      redirect_to relationship_path(@relationship)
    else
      render :edit
    end
  end

  # Creates a new Relationship and a Reference
  # Returns status code 201 if successful or a json of errors with status code 400
  def create
    @relationship = Relationship.new(relationship_params)
    @reference = Reference.new(reference_params)

    if @relationship.valid? and @reference.validate_before_create.empty?
      @relationship.save!
      @reference.assign_attributes(object_id: @relationship.id, object_model: "Relationship")
      @reference.save
      # updated last_user_id of the entities in the relationship
      update_entity_last_user
      render json: {'relationship_id' => @relationship.id}, status: :created
    else
      errors = {
        relationship: @relationship.errors.to_h,
        reference: @reference.validate_before_create
      }
      render json: errors, status: :bad_request
    end
  end

  # POST /relationships/:id/reverse_direction
  def reverse_direction
    @relationship.reverse_direction
    redirect_to :action => "edit", :id => @relationship.id
  end

  # POST /relationships/bulk_add
  # four possible status codes can be returned: 201, 207, 400, 422
  def bulk_add
    check_permission 'importer'
    return head :bad_request unless Reference.new(reference_params).validate_before_create.empty?
    @errors = 0
    entity1 = Entity.find(params.fetch('entity1_id'))

    # Looping through each relationship
    bulk_relationships_params.each do |relationship|
      # creating or finding the entity for that relationship
      make_or_get_entity(relationship) do |entity2|
        r = Relationship.create relationship_attributes(entity1, entity2, relationship)
        # if the relationship is not persisted (meaning an error occurred)
        @errors += 1 and next unless r.persisted?
        # creating the reference for that relationship
        Reference.create(reference_params.merge(object_id: r.id, object_model: 'Relationship'))
        # some relationships will have additional fields:
        if extension?
          # get only the category fields from the relationship hash
          new_category_attr = relationship.delete_if { |key| (r.attributes.keys + ['name', 'primary_ext', 'blurb']).include? key }
          # update relationship category - we don't have to update if nothing has changed
          r.get_category.update(new_category_attr) unless r.category_attributes == new_category_attr
        end
      end
    end # end loop of submitted relationships

    # This will returns three possible status codes
    # - 201 if all relationships are created
    # - 422 if none of the relationships are created
    # - 207 if some but not all of the relationships are created
    if @errors.zero?
      head :created
    elsif @errors == bulk_relationships_params.length
      head :unprocessable_entity
    else
      render json: { 'errors' => @errors }, status: :multi_status
    end
  end

  private

  # Hash -> Nil | yield
  def make_or_get_entity(relationship)
    if relationship.fetch('name').to_i.zero?
      attributes = relationship.slice('name', 'blurb', 'primary_ext').merge('last_user_id' => current_user.sf_guard_user_id)
      entity = Entity.create(attributes)
    else
      entity = Entity.find_by_id(relationship.fetch('name').to_i)
    end
    if entity.persisted?
      yield entity
    else
      @errors += 1
    end
  end

  def extension?
    [1, 2, 3, 10].include? params.require(:category_id).to_i
  end

  # <Entity>, <Entity>, Hash -> Hash
  def relationship_attributes(entity1, entity2, relationship)
    r = {
      entity1_id: entity1.id,
      entity2_id: entity2.id,
      category_id: params.require(:category_id),
      description1: relationship.fetch('description1', nil),
      description2: relationship.fetch('description2', nil),
      start_date: relationship.fetch('start_date', nil),
      end_date: relationship.fetch('end_date', nil),
      goods: relationship.fetch('goods', nil),
      is_current: relationship.fetch('is_current', nil),
      last_user_id: current_user.sf_guard_user_id
    }
    if r[:category_id].to_i == 1 && entity1.org? && entity2.person?
      r[:entity1_id] = entity2.id
      r[:entity2_id] = entity1.id
    end
    r
  end

  def set_relationship
    @relationship = Relationship.find(params[:id])
  end

  def update_entity_last_user
    @relationship.entity.update(last_user_id: current_user.sf_guard_user_id)
    @relationship.related.update(last_user_id: current_user.sf_guard_user_id)
  end


  def bulk_relationships_params
    return params[:relationships].map { |x| blank_to_nil(x) } if params[:relationships].is_a?(Array)
    params[:relationships].to_a.map { |x| x[1] }.map { |x| blank_to_nil(x) }
  end

  def relationship_params
    params.require(:relationship).permit(:entity1_id, :entity2_id, :category_id)
  end

  def reference_params
    params.require(:reference).permit(:name, :source, :source_detail, :publication_date, :ref_type)
  end

  def existing_reference_params
    params.require(:reference).permit(:just_cleaning_up, :reference_id)
  end

  
  # whitelists relationship params and associated nested attributes
  # if the relationship category requires them 
  def update_params
    relationship_fields = @relationship.attribute_names.map(&:to_sym)
    if Relationship.all_category_ids_with_fields.include? @relationship.category_id
      category_fields = @relationship.get_category.attribute_names.map(&:to_sym)
      relationship_fields.push("#{@relationship.category_name.downcase}_attributes".to_sym => category_fields)
    end
    params.require(:relationship).permit(*relationship_fields)
  end
end
