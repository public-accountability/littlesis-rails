# frozen_string_literal: true

class ListsController < ApplicationController
  include TagableController
  include ListPermissions

  EDITABLE_ACTIONS = %i[create update destroy].freeze
  SIGNED_IN_ACTIONS = (EDITABLE_ACTIONS + %i[new edit modifications tags]).freeze

  # The call to :authenticate_user! on the line below overrides the :authenticate_user! call
  # from TagableController and therefore including :tags in the list is required
  # Because of the potential for confusion, perhaps we should no longer use :authenticate_user!
  # in controller concerns? (ziggy 2017-08-31)
  before_action :authenticate_user!, only: SIGNED_IN_ACTIONS
  before_action :block_restricted_user_access, only: SIGNED_IN_ACTIONS
  before_action :set_list, only: [:show, :edit, :update, :destroy, :members, :references,
                                  :modifications]

  before_action :set_permissions, only: [:members, :references, :edit, :update, :destroy]
  # before_action :set_entity, only: :index
  before_action -> { check_access(:viewable) }, only: [:members, :references]
  before_action -> { check_access(:configurable) }, only: [:destroy, :edit, :update]

  before_action -> { current_user.raise_unless_can_edit! }, only: EDITABLE_ACTIONS

  before_action :set_page, only: [:modifications]

  def index
    lists_query = ListsIndexQuery.new
    lists_query.page(params[:page] || 1)
    lists_query.only_featured if params[:only_featured]
    lists_query.for_entity(params[:entity_id]) if params[:entity_id]

    @lists = lists_query.run(params[:q] || '')

    # @lists = search_lists(available_scope)
    #            .force_reorder(params[:sort_by], params[:order])
    #            .page(page)
    #            .per(per)

    respond_to do |format|
      format.html
      format.json { render json: format_lists(@lists) }
    end
  end

  def show
    redirect_to action: 'members'
  end

  def new
    @list = List.new
  end

  def edit
  end

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

  def update
    render action: 'edit' unless @list.update(list_params)

    @list.clear_cache(request.host)

    if params[:redirect_to]
      redirect_to params[:redirect_to], notice: 'List was successfully updated.'
    else
      redirect_back(fallback_location: members_list_path(@list),
                    notice: 'List was successfully updated.')
    end
  end

  def destroy
    @list.soft_delete
    redirect_to lists_path, notice: 'List was successfully destroyed.'
  end

  def members
    @table = ListDatatable.new(@list)
    @table.generate_data

    @datatable_config = {
      list_id: @list.id,
      update_path: list_list_entity_path(@table.list),
      editable: @permissions[:editable],
      ranked_table: @table.ranked?,
      sort_by: @list.sort_by
    }
  end

  def references
  end

  def modifications
  end

  private

  def set_list
    @list = List.find(params[:id])
  end

  def set_entity
    @entity = Entity.find(params[:entity_id]) if params[:entity_id].present?
  end

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
