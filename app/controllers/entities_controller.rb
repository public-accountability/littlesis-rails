# frozen_string_literal: true

class EntitiesController < ApplicationController
  include TagableController
  include ReferenceableController
  include EntitiesHelper

  ERRORS = ActiveSupport::HashWithIndifferentAccess.new(
    create_bulk: {
      errors: [{ 'title' => 'Could not create new entities: request formatted improperly' }]
    }
  )

  EDITABLE_ACTIONS = %i[create update destroy create_bulk match_donation].freeze
  IMPORTER_ACTIONS = %i[match_donation match_donations review_donations].freeze

  before_action :authenticate_user!, except: [:show, :datatable, :political, :contributions, :references, :interlocks, :giving, :validate]
  before_action :block_restricted_user_access, only: [:new, :create, :update, :create_bulk]
  before_action -> { current_user.raise_unless_can_edit! }, only: EDITABLE_ACTIONS
  before_action :importers_only, only: IMPORTER_ACTIONS
  before_action :set_entity, except: [:new, :create, :show, :create_bulk, :validate]
  before_action :set_entity_for_profile_page, only: [:show]
  before_action :set_tab_for_profile_page, only: [:show]
  before_action :check_delete_permission, only: [:destroy]

  def show
  end

  def political
  end

  # THE DATA 'tab'
  def datatable
  end

  def create_bulk
    # only responds to JSON, not possible to create extensions in POSTS to this endpoint
    entity_attrs = create_bulk_payload.map { |x| merge_last_user(x) }
    block_unless_bulker(entity_attrs, Entity::BULK_LIMIT) # see application_controller
    entities = Entity.create!(entity_attrs)
    render json: Api.as_api_json(entities), status: :created
  rescue ActionController::ParameterMissing, NoMethodError, ActiveRecord::RecordInvalid
    render json: ERRORS[:create_bulk], status: 400
  end

  def new
    @entity = Entity.new(name: params[:name]) if params[:name].present?
  end

  def create
    @entity = Entity.new(new_entity_params)

    if @entity.save # successfully created entity
      params[:types].each { |type| @entity.add_extension(type) } if params[:types].present?

      if wants_json_response?
        render json: {
                 status: 'OK',
                 entity: {
                   id: @entity.id,
                   name: @entity.name,
                   description: @entity.blurb,
                   url: @entity.url,
                   primary_ext: @entity.primary_ext
                 }
               }
      else
        redirect_to concretize_edit_entity_path(@entity)
      end

    else # encounted error

      if wants_json_response?
        render json: { status: 'ERROR', errors: @entity.errors.messages }
      else
        render action: 'new'
      end

    end
  end

  def edit
    set_entity_references
  end

  def update
    EntityUpdateService.run(entity: @entity,
                            params: params,
                            current_user: current_user)

    if @entity.valid?
      return render json: { status: 'OK' } if api_request?
      return redirect_to concretize_entity_path(@entity)
    else
      set_entity_references
      render :edit
    end
  end

  def destroy
    @entity.soft_delete
    redirect_to home_dashboard_path, notice: "#{@entity.name} has been successfully deleted"
  end

  def add_relationship
    @relationship = Relationship.new
    @reference = Reference.new
  end

  def references
    @documents = @entity
                   .documents
                   .order(created_at: :desc)
                   .page(params[:page] || 1)
                   .per(20)
  end

  # ------------------------------ #
  # Open Secrets Donation Matching #
  # ------------------------------ #

  def match_donations
    redirect_to fec_entity_match_contributions_path(@entity)
  end

  def review_donations
  end

  def match_donation
    params[:payload].each do |donation_id|
      match = OsMatch.find_or_create_by(os_donation_id: donation_id, donor_id: params[:id])
      match.update(matched_by: current_user.id)
    end
    @entity.update(last_user_id: current_user.id)
    render json: { status: 'ok' }
  end

  def unmatch_donation
    check_permission 'importer'
    params[:payload].each do |os_match_id|
      OsMatch.find(os_match_id).destroy
    end
    @entity.update(last_user_id: current_user.id)
    render json: { status: 'ok' }
  end

  # ------------------------------ #
  # Open Secrets Contributions     #
  # ------------------------------ #

  def contributions
    expires_in(5.minutes, public: true)
    render json: @entity.contribution_info
  end

  def potential_contributions
    render json: @entity.potential_contributions
  end

  def validate
    essential_entity_attributes = params.require(:entity).permit(:name, :blurb, :primary_ext).to_h
    entity = Entity.new(essential_entity_attributes)
    entity.valid?
    render json: entity.errors.to_json
  end

  private

  def set_entity_for_profile_page
    set_entity(:profile_scope)
  end

  def set_entity_references
    @references = @entity.references.order('updated_at desc').limit(10)
  end

  def new_entity_params
    Entity::Parameters.new(params).new_entity(current_user)
  end

  def create_bulk_payload
    params
      .require('data')
      .map { |r| r.permit('attributes' => %w[name blurb primary_ext])['attributes'] }
  end

  def wants_json_response?
    params[:add_relationship_page].present? || params[:external_entity_page].present?
  end

  def importers_only
    check_permission 'importer'
  end

  def check_delete_permission
    unless current_user.permissions.entity_permissions(@entity).fetch(:deleteable)
      raise Exceptions::PermissionError
    end
  end

  def set_tab_for_profile_page
    @active_tab = params.fetch(:tab, :relationships)
  end
end
