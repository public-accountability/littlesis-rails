# frozen_string_literal: true

class RelationshipsController < ApplicationController
  include TagableController
  include ReferenceableController

  before_action :authenticate_user!, :current_user_can_edit?, except: [:show]
  before_action -> { check_ability(:star_relationship) }, only: [:feature]
  before_action :set_relationship, only: [:show, :edit, :update, :destroy, :reverse_direction, :feature]
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
    :is_current
  ].freeze

  PERMITTED_RELATIONSHIP_PARAMS = (1..12).each_with_object({}) do |i, h|
    if Relationship.category_has_fields?(i)
      parameter_name = "#{Relationship::ALL_CATEGORIES[i].downcase}_attributes".to_sym
      category_fields = Relationship.attribute_fields_for(i)
      h.store i, (PERMITTED_FIELDS.dup + [{ parameter_name => category_fields }]).freeze
    else
      h.store i, PERMITTED_FIELDS
    end
  end.freeze

  rescue_from Exceptions::MissingCategoryIdParamError do |exception|
    render json: {error: exception.message }, status: :bad_request
  end

  def show; end

  # GET /relationships/:id/edit
  def edit
    @selected_document_id = params[:new_ref].present? ? @relationship.documents.last&.id : nil
  end

  def add_source
    @relationship = Relationship.find(params[:id])
    render partial: 'shared/reference_new', locals: {model: @relationship, reference: @reference }
  end

  def edit_relationship
    @relationship = Relationship.find(params[:id])
    render partial: 'edit_relationship'
  end

  def edit_tags
    @relationship = Relationship.find(params[:id])
    render partial: 'edit_tags'
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

  # PATCH /relationship/:id/feature { is_featured: Boolean }
  #
  def feature
    @relationship.update!(is_featured: ParametersHelper.cast_to_boolean(params.require(:is_featured)))
    return redirect_back fallback_location: relationship_path(@relationship)
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
      render json: { 'relationship_id' => @relationship.id,
                     'url' => @relationship.url,
                     'path' => edit_relationship_path(@relationship) }, status: :created
    else
      Rails.logger.warn @relationship.errors.full_messages
      render json: { error: @relationship.errors.full_messages }, status: :bad_request
    end
  end

  def destroy
    unless @relationship.permissions_for(current_user).fetch(:deleteable)
      raise Exceptions::PermissionError
    end

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
  # Bulk add page
  def bulk_add
  end

  # POST /relationships/bulk_add
  def bulk_add!
    block_unless_bulker(params.require(:relationships), Relationship::BULK_LIMIT)

    if !Document.valid_url?(reference_params.fetch(:url)) || reference_params.fetch(:name).blank?
      return head :bad_request
    end

    service = Relationship::BulkCreationService.run(params)

    # Always send back a successful response, even if every relationship is an error
    render :json => { errors: service.errored_relationships, relationships: service.successful_relationships }
  end

  private

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

  # whitelists relationship params and associated nested attributes if the relationship category requires them
  def relationship_params
    unless (category_id = @relationship&.category_id)
      begin
        category_id = params.require(:relationship).require(:category_id).to_i
      rescue ActionController::ParameterMissing
        raise Exceptions::MissingCategoryIdParamError
      end
    end

    prepare_params params.require(:relationship).permit(*PERMITTED_RELATIONSHIP_PARAMS[category_id])
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
    p.key?(:entity1_id) && p.key?(:entity2_id) && p.key?(:category_id)
  end

  def reverse_direction?
    ParametersHelper.cast_to_boolean(params[:reverse_direction]) && @relationship.reversible?
  end
end
