# frozen_string_literal: true

class RelationshipsController < ApplicationController
  include TagableController
  include ReferenceableController
  before_action :set_relationship, only: [:show, :edit, :update, :destroy, :reverse_direction]
  before_action :authenticate_user!, except: [:show]
  before_action :current_user_can_edit?, only: [:create, :update, :destroy, :bulk_add, :reverse_direction]
  # TODO
  before_action :check_delete_permission, only: [:destroy]
  before_action :set_entity, only: [:bulk_add]

  # see utility.js
  BULK_RELATIONSHIP_ATTRIBUTES = [
    :name,
    :blurb,
    :primary_ext,
    :description1,
    :description2,
    :is_current,
    :start_date,
    :end_date,
    :amount,
    :currency,
    :goods,
    :is_board,
    :is_executive,
    :compensation,
    :degree,
    :education_field,
    :is_dropout,
    :dues,
    :percent_stake,
    :shares,
    :notes
  ].freeze

  PERMITTED_FIELDS = [
    :entity1_id,
    :entity2_id,
    :category_id,
    :description1,
    :description2,
    :amount,
    :currency,
    :goods,
    :notes,
    :start_date,
    :end_date,
    :is_current,
    :is_featured
  ].freeze

  rescue_from Exceptions::MissingCategoryIdParamError do |exception|
    render json: exception.error_hash, status: :bad_request
  end

  def show; end

  # GET /relationships/:id/edit
  def edit
    @selected_document_id = params[:new_ref].present? ? @relationship.documents.last&.id : nil
  end

  # PATCH /relationships/:id
  #
  # if the parameter "reverse_direction" is passed with this request,
  # it also reverse the direction of the relationship
  def update
    @relationship.assign_attributes relationship_params

    # If user has not checked the 'just cleaning up' or selected an existing reference
    # then a new reference must be created
    @relationship.validate_reference(reference_params) if need_to_create_new_reference
    if @relationship.valid?
      ApplicationRecord.transaction do
        @relationship.add_reference(reference_params) if need_to_create_new_reference

        if @relationship.valid?
          @relationship.save!
          flash[:notice] = 'Relationship updated'
          @relationship.reverse_direction! if reverse_direction?
          update_entity_last_user
        end
      end
    end

    if @relationship.valid?
      return redirect_back fallback_location: relationship_path(@relationship)
    else
      return render :edit
    end
  end

  # Creates a new Relationship and a Reference
  # Returns status code 201 if successful or a json of errors with status code 400
  def create
    @relationship = Relationship.new(relationship_params)
    @relationship.validate_reference(reference_params) unless existing_document_id

    if @relationship.valid?
      @relationship.save!
      if existing_document_id
        @relationship.references.find_or_create_by(document_id: existing_document_id)
      else
        @relationship.add_reference(reference_params)
      end

      update_entity_last_user
      render json: { 'relationship_id' => @relationship.id }, status: :created
    else
      render json: @relationship.errors.to_hash, status: :bad_request
    end
  end

  def destroy
    @relationship.current_user = current_user
    @relationship.soft_delete

    redirect_to home_dashboard_path, notice: 'Relationship successfully deleted'
  end

  # POST /relationships/:id/reverse_direction
  def reverse_direction
    @relationship.reverse_direction!
    respond_to do |format|
      format.html { redirect_to :action => "edit", :id => @relationship.id }
      format.json { render json: { status: 'ok' } }
    end
  end

  def find_similar
    if has_required_find_similar_params?
      render json: Relationship.find_similar(similar_relationships_params).map { |r| r.as_json(:url => true) }
    else
      head :bad_request
    end
  end

  # GET /relationships/bulk_add
  def bulk_add; end

  # POST /relationships/bulk_add
  def bulk_add!
    block_unless_bulker(bulk_relationships_params, Relationship::BULK_LIMIT) # see application_controller

    if !Document.valid_url?(reference_params.fetch(:url)) || reference_params.fetch(:name).blank?
      return head :bad_request
    end

    @errors = []
    @new_relationships = []

    entity1 = Entity.find(params.require('entity1_id'))

    # Looping through each relationship
    bulk_relationships_params.each do |relationship|
      ApplicationRecord.transaction do
        make_or_get_entity(relationship) do |entity2|
          rollback_if(relationship) do
            create_bulk_relationship(entity1, entity2, relationship)
          end
        end
      end
    end # end loop of submitted relationships

    # Always send back a successful response,
    # even if every relationship is an error
    render :json => bulk_json_response
  end

  private

  ####################
  # Bulk Add Helpers #
  ####################

  # Hash -> Nil | yield
  # creating or finding the entity for the relationship
  def make_or_get_entity(relationship)
    if relationship.fetch('name').to_i.zero?
      attributes = relationship.slice('name', 'blurb', 'primary_ext').merge('last_user_id' => current_user.id)
      entity = Entity.create(attributes)
    else

      entity = Entity.find_by(id: relationship.fetch('name').to_i)
    end

    if entity.try(:persisted?)
      yield entity
    else
      @errors << relationship.merge('errorMessage' => 'Failed to find or create entity')
    end
  end

  def rollback_if(relationship)
    yield
  rescue ActiveRecord::StatementInvalid
    # The rails documentation recommends not catching this exception: http://api.rubyonrails.org/classes/ActiveRecord/Transactions/ClassMethods.html
    # ...and we shall OBEY the rails docs...
    raise
  rescue ActiveRecord::ActiveRecordError => e
    @errors << relationship.merge('errorMessage' => e.message)
    Rails.logger.warn "BulkAdd Relationship Error: #{e.message}"
    raise ActiveRecord::Rollback, "Error creating a Relationship"
  end

  def create_bulk_relationship(entity1, entity2, relationship)
    r = Relationship.new(relationship_attributes(entity1, entity2, relationship))
    r.validate_reference(reference_params)
    if r.valid?
      r.save!
      r.add_reference(reference_params)
      if extension?
        # get only the category fields from the relationship hash
        new_category_attr = relationship.delete_if { |key| (r.attributes.keys + ['name', 'primary_ext', 'blurb']).include? key }
        # update relationship category - we don't have to update if nothing has changed
        r.get_category.update!(new_category_attr) unless r.category_attributes == new_category_attr
      end
    else
      raise ActiveRecord::ActiveRecordError, r.errors.full_messages
    end
    @new_relationships << r.as_json(:url => true, :name => true)
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
      notes: relationship.fetch('notes', nil),
      amount: relationship.fetch('amount', nil),
      currency: relationship.fetch('currency', nil),
      is_current: relationship.fetch('is_current', nil),
      last_user_id: current_user.id
    }

    if [1, 2].include?(r[:category_id].to_i) && entity1.org? && entity2.person?
      r[:entity1_id] = entity2.id
      r[:entity2_id] = entity1.id
    end

    # 30, 31, 50, and 51 represent special categories
    # see helpers/tools_helper.rb
    if [30, 31, 50, 51].include? r[:category_id].to_i
      if r[:category_id].to_i == 50 || r[:category_id].to_i == 31
        r[:entity1_id] = entity2.id
        r[:entity2_id] = entity1.id
      end
      r[:category_id] = r[:category_id].to_s[0]
    end

    prepare_params(r)
  end

  def bulk_json_response
    { errors: @errors, relationships: @new_relationships }
  end

  def bulk_relationships_params
    params
      .require(:relationships)
      .map { |p| blank_to_nil(p.permit(*BULK_RELATIONSHIP_ATTRIBUTES).to_h) }
  end

  #################
  # Other Helpers #
  #################

  def extension?
    [1, 2, 3, 10].include? params.require(:category_id).to_i
  end

  def set_relationship
    @relationship = Relationship.find(params[:id])
  end

  def set_entity
    @entity = Entity.find(params.require(:entity_id))
  end

  def update_entity_last_user
    @relationship.entity.update(last_user_id: current_user.id)
    @relationship.related.update(last_user_id: current_user.id)
  end

  # whitelists relationship params and associated nested attributes
  # if the relationship category requires them
  def relationship_params
    relationship_fields = PERMITTED_FIELDS.dup

    unless (category_id = @relationship&.category_id)
      begin
        category_id = params.require(:relationship).require(:category_id).to_i
      rescue ActionController::ParameterMissing
        raise Exceptions::MissingCategoryIdParamError
      end
    end

    if Relationship.category_has_fields?(category_id)
      category_fields = Relationship.attribute_fields_for(category_id)
      category_name = Relationship::ALL_CATEGORIES.fetch(category_id).downcase
      relationship_fields.push("#{category_name}_attributes".to_sym => category_fields)
    end

    prepare_params params.require(:relationship).permit(*relationship_fields)
  end

  def parameter_processor(p)
    if p.dig('position_attributes', 'is_board')
      p['position_attributes']['is_board'] = cast_to_boolean(p.dig('position_attributes', 'is_board'))
    end

    if p.dig('position_attributes', 'compensation')
      p['position_attributes']['compensation'] = money_to_int(p.dig('position_attributes', 'compensation'))
    end
    p
  end

  def similar_relationships_params
    params.permit(:entity1_id, :entity2_id, :category_id)
  end

  def has_required_find_similar_params?
    p = similar_relationships_params
    return true if p.key?(:entity1_id) && p.key?(:entity2_id) && p.key?(:category_id)
    return false
  end

  def reverse_direction?
    cast_to_boolean(params[:reverse_direction]) && @relationship.reversible?
  end

  def check_delete_permission
    unless current_user.permissions.relationship_permissions(@relationship).fetch(:deleteable)
      raise Exceptions::PermissionError
    end
  end
end
