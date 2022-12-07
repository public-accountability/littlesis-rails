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
  MATCH_DONTAIONS_ACTIONS = %i[match_donation match_donations review_donations].freeze

  before_action :authenticate_user!, :current_user_can_edit?, except: PUBLIC_ACTIONS
  before_action -> { check_ability(:match_donation) }, only: MATCH_DONTAIONS_ACTIONS
  before_action :set_entity, except: [:new, :create, :create_bulk, :validate, :show]
  before_action :set_entity_for_profile_page, only: [:show]

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
    entity_attrs = create_bulk_payload.map { |x| x.merge(last_user_id: current_user.id) }
    block_unless_bulker(entity_attrs, Entity::BULK_LIMIT) # see application_controller
    entities = Entity.create!(entity_attrs)
    render json: Api.as_api_json(entities), status: :created
  rescue ActionController::ParameterMissing, NoMethodError, ActiveRecord::RecordInvalid
    render json: ERRORS[:create_bulk], status: :bad_request
  end

  def new
    @entity = Entity.new(name: params[:name].presence)
    if turbo_frame_request?
      render partial: 'new_entity_form', locals: { entity: @entity,
                                                   add_relationship_page: request.referer.include?("add_relationship") }
    end
  end

  def create
    @entity = Entity.new(new_entity_params)

    if @entity.save
      add_extensions
    end

    if @entity.persisted?
      if request.format.json?
        render json: json_success_response
      elsif turbo_frame_request?
        render partial: 'new_entity_result'
      else
        redirect_to concretize_edit_entity_path(@entity)
      end
    else
      if request.format.json?
        render json: { status: 'ERROR', errors: @entity.errors.messages }
      elsif turbo_frame_request?
        render partial: 'new_entity_form', locals: { entity: @entity }
      else
        render 'new'
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
    unless @entity.deleteable_by?(current_user)
      raise Exceptions::PermissionError
    end

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
