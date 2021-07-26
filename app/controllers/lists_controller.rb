# frozen_string_literal: true

class ListsController < ApplicationController
  include TagableController
  include ListPermissions

  EDITABLE_ACTIONS = %i[create update destroy crop_images].freeze
  SIGNED_IN_ACTIONS = (EDITABLE_ACTIONS + %i[new edit admin update_cache modifications tags]).freeze

  # The call to :authenticate_user! on the line below overrides the :authenticate_user! call
  # from TagableController and therefore including :tags in the list is required
  # Because of the potential for confusion, perhaps we should no longer use :authenticate_user!
  # in controller concerns? (ziggy 2017-08-31)
  before_action :authenticate_user!, only: SIGNED_IN_ACTIONS
  before_action :block_restricted_user_access, only: SIGNED_IN_ACTIONS
  before_action :set_list,
                only: [:show, :edit, :update, :destroy, :search_data, :admin, :crop_images,
                       :members, :clear_cache, :find_entity, :delete, :references, :modifications]

  # permissions
  before_action :set_permissions,
                only: [:members, :references, :edit, :update,
                       :destroy, :add_entity, :remove_entity, :update_entity]
  before_action :set_entity, only: :index
  before_action -> { check_access(:viewable) }, only: [:members, :references]
  before_action -> { check_access(:configurable) }, only: [:destroy, :edit, :update]

  before_action -> { current_user.raise_unless_can_edit! }, only: EDITABLE_ACTIONS

  before_action :set_page, only: [:modifications]

  # GET /lists
  def index
    page = params[:page] || 1
    per = 20

    @lists = search_lists(available_scope)
      .force_reorder(params[:sort_by], params[:order])
      .page(page)
      .per(per)

    respond_to do |format|
      format.html
      format.json { render json: format_lists(@lists) }
    end
  end

  # GET /lists/1
  def show
    redirect_to action: 'members'
  end

  # GET /lists/new
  def new
    @list = List.new
  end

  # GET /lists/1/edit
  def edit
  end

  # POST /lists
  def create
    @list = List.new(list_params)
    @list.creator_user_id = current_user.id
    @list.last_user_id = current_user.id

    ref_params = params.permit(ref: [:url, :name])[:ref]&.to_h&.keep_if do |_, v|
      v.present?
    end.presence
    @list.validate_reference(ref_params) if ref_params

    if @list.valid?
      @list.save!
      @list.add_reference(ref_params) if ref_params
      redirect_to @list, notice: 'List was successfully created.'
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /lists/1
  def update
    if @list.update(list_params)
      @list.clear_cache(request.host)

      if params[:redirect_to]
        redirect_to params[:redirect_to], notice: 'List was successfully updated.'
      else
        redirect_back(fallback_location: members_list_path(@list),
                      notice: 'List was successfully updated.')
      end
    else
      render action: 'edit'
    end
  end

  def destroy
    # check_permission 'admin'

    @list.soft_delete
    redirect_to lists_path, notice: 'List was successfully destroyed.'
  end

  def admin
  end

  def crop_images
    check_permission 'importer'
    entity_ids = @list.entities.joins(:images).where(image: { is_featured: true }).group('entity.id').order('image.updated_at ASC').pluck(:id)
    set_entity_queue(:crop_images, entity_ids, @list.id)
    next_entity_id = next_entity_in_queue(:crop_images)
    image_id = Image.where(entity_id: next_entity_id, is_featured: true).first
    redirect_to crop_image_path(id: image_id)
  end

  def members
    @table = ListDatatable.new(@list)
    @table.generate_data

    @datatable_config = {
      update_path: list_list_entity_path(@table.list),
      editable: @permissions[:editable],
      ranked_table: @table.ranked?,
      sort_by: @list.sort_by
    }
  end

  def clear_cache
    @list.clear_cache(request.host)
    render json: { status: 'success' }
  end

  def references
  end

  def modifications
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_list
    @list = List.find(params[:id])
  end

  def set_entity
    @entity = Entity.find(params[:entity_id]) if params[:entity_id].present?
  end

  # Only allow a trusted parameter "white list" through.
  def list_params # rubocop:disable Metrics/MethodLength
    params.require(:list)
      .permit(
        :name,
        :description,
        :is_ranked,
        :sort_by,
        :is_admin,
        :is_featured,
        :is_private,
        :custom_field_name,
        :short_description,
        :access
      )
  end

  # def reference_params
  #   @reference_params ||= params.require(:ref).permit(:url, :name).to_h
  # end

  def after_tags_redirect_url(list)
    edit_list_url(list)
  end

  def check_tagable_access(list)
    unless current_user.permissions.list_permissions(list)[:configurable]
      raise Exceptions::PermissionError
    end
  end

  def basic_scope
    scope = List.viewable(current_user)

    ActiveModel::Type::Boolean.new.cast(params[:featured]) ? scope.featured : scope
  end

  def available_scope
    return basic_scope unless @entity

    basic_scope.where(id: @entity.lists.pluck(:id))
  end

  def search_lists(lists)
    return lists if params[:q].blank?

    ids = List.search_for_ids(
      Riddle::Query.escape(params[:q]),
      with: { is_deleted: 0, is_admin: search_admin_param }
    )
    lists.where(id: ids)
  end

  def search_admin_param
    current_user&.admin? ? [0, 1] : 0
  end

  def format_lists(lists)
    { results: lists.map { |l| l.attributes.merge(text: l.name) } }
  end
end
