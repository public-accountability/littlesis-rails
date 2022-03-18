# frozen_string_literal: true

class EntitiesController < ApplicationController
  include TagableController
  include ReferenceableController
  include EntitiesHelper

  ERRORS = ActiveSupport::HashWithIndifferentAccess.new(
    create_bulk: {
      errors: [{ 'title' => 'Could not create new entities: request formatted improperly' }]
    }
  ).freeze

  PUBLIC_ACTIONS = %i[show datatable political contributions references validate profile grouped_links source_links].freeze
  EDITABLE_ACTIONS = %i[new create update destroy create_bulk].freeze
  MATCH_DONTAIONS_ACTIONS = %i[match_donation match_donations review_donations].freeze

  before_action :authenticate_user!, except: PUBLIC_ACTIONS
  before_action :current_user_can_edit?, only: EDITABLE_ACTIONS
  before_action -> { current_user.role.include?(:match_donation) }, only: MATCH_DONTAIONS_ACTIONS
  # before_action :importers_only, only: IMPORTER_ACTIONS
  before_action :set_entity, except: [:new, :create, :show, :create_bulk, :validate]
  before_action :set_entity_for_profile_page, only: [:show]
  before_action :check_delete_permission, only: [:destroy]

  rescue_from Exceptions::RestrictedUserError, with: -> { head :forbidden }

  # profile page
  def show
    @active_tab = params[:active_tab]&.to_sym || :relationships

    if %i[interlocks giving].include?(@active_tab)
      @page = params[:page]&.to_i || 1
    end

    render :profile
  end

  # Old "data" table
  def datatable
    redirect_to concretize_profile_entity_path(@entity, active_tab: :data)
  end

  def grouped_links # turbo frame
    @subcategory_page = params.require(:page).to_i
    @subcategory = params.require(:subcategory).to_sym
    render partial: 'grouped_links_cache'
  end

  def source_links # turbo frame
    render partial: 'source_links'
  end

  def political  # currently disabled
  end

  def create_bulk
    # only responds to JSON, not possible to create extensions in POSTS to this endpoint
    entity_attrs = create_bulk_payload.map { |x| merge_last_user(x) }
    block_unless_bulker(entity_attrs, Entity::BULK_LIMIT) # see application_controller
    entities = Entity.create!(entity_attrs)
    render json: Api.as_api_json(entities), status: :created
  rescue ActionController::ParameterMissing, NoMethodError, ActiveRecord::RecordInvalid
    render json: ERRORS[:create_bulk], status: :bad_request
  end

  def new
    @entity = Entity.new(name: params[:name]) if params[:name].present?
  end

  def create
    @entity = Entity.new(new_entity_params)

    if wants_json_response?
      handle_json_creation
    else
      handle_creation
    end
  end

  def edit
    set_entity_references
  end

  def update
    EntityUpdateService.run(entity: @entity,
                            params: params,
                            current_user: current_user)

    if api_request? || request.format.json?
      status = @entity.valid? ? :ok : :bad_request
      return render json: { status: status }, status: status
    end

    if @entity.valid?
      redirect_to concretize_entity_path(@entity)
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
    # TODO: rewirte call for current_user.permissions.entity_permissions(@entity)
    check_ability :edit_destructively
  end

  def handle_creation
    if @entity.save
      add_extensions
      redirect_to concretize_edit_entity_path(@entity)
    else
      render action: 'new'
    end
  end

  def handle_json_creation
    if @entity.save
      add_extensions
      render json: json_success_response
    else
      render json: { status: 'ERROR', errors: @entity.errors.messages }
    end
  end

  def add_extensions
    params[:types].each { |type| @entity.add_extension(type) } if params[:types].present?
  end

  def json_success_response
    {
      status: 'OK',
      entity: {
        id: @entity.id,
        name: @entity.name,
        description: @entity.blurb,
        url: @entity.url,
        primary_ext: @entity.primary_ext
      }
    }
  end
end
