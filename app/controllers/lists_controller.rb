# frozen_string_literal: true

class ListsController < ApplicationController
  include TagableController
  include ListPermissions

  PUBLIC_ACTIONS = %i[index show members references].freeze

  before_action :authenticate_user!, except: PUBLIC_ACTIONS
  before_action -> { check_ability :create_list }, except: PUBLIC_ACTIONS
  before_action :set_list, :set_permissions, except: [:index, :new, :create, :tags]
  before_action -> { check_access(:viewable) }, except: [:index, :new, :create, :tags]
  before_action -> { check_access(:configurable) }, only: [:update, :edit, :modifications]
  before_action :set_page, only: [:modifications]

  def index
    params.with_defaults!(order_column: :created_at, order_direction: :desc)
    lists_query = ListsIndexQuery.new
    lists_query.page(params[:page] || 1)
    lists_query.only_featured if ParametersHelper.cast_to_boolean(params[:featured])
    lists_query.for_entity(params[:entity_id]) if params[:entity_id]
    unless params[:order_direction].empty?
      lists_query.order_by(params[:order_column].to_sym, params[:order_direction].to_sym)
    end

    @lists = lists_query.run(params[:q] || '')

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
    @list.access = Permissions::ACCESS_PRIVATE unless current_user.role.include?(:edit_list)

    ref_params = params.permit(ref: [:url, :name])[:ref]&.to_h&.keep_if do |_, v|
      v.present?
    end.presence

    @list.validate_reference(ref_params) if ref_params

    if @list.valid?
      @list.save!
      @list.add_reference(ref_params) if ref_params
      redirect_to members_list_path(@list), notice: 'List was successfully created.'
    else
      render action: 'new'
    end
  end

  def update
    render action: 'edit' unless @list.update(list_params)

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

  def list_params
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

  # @param list [List]
  def check_tagable_access(list)
    unless list.permissions_for(current_user).configurable
      raise Exceptions::PermissionError
    end
  end

  def format_lists(lists)
    { results: lists.map { |l| l.attributes.merge(text: l.name) } }
  end
end
