# frozen_string_literal: true

class ListsController < ApplicationController
  include TagableController

  ERRORS = ActiveSupport::HashWithIndifferentAccess.new(
    entity_associations_bad_format: {
      errors: [{ title: 'Could not add entities to list: improperly formatted request.' }]
    },
    entity_associations_invalid_reference: {
      errors: [{ title: 'Could not add entities to list: invalid reference.' }]
    }
  )

  EDITABLE_ACTIONS = %i[create update add_entity destroy crop_images remove_entity update_entity create_entity_associations].freeze
  SIGNED_IN_ACTIONS = (EDITABLE_ACTIONS + %i[new edit admin update_cache new_entity_associations modifications tags]).freeze

  # The call to :authenticate_user! on the line below overrides the :authenticate_user! call
  # from TagableController and therefore including :tags in the list is required
  # Because of the potential for confusion, perhaps we should no longer use :authenticate_user!
  # in controller concerns? (ziggy 2017-08-31)
  before_action :authenticate_user!, only: SIGNED_IN_ACTIONS
  before_action :block_restricted_user_access, only: SIGNED_IN_ACTIONS
  before_action :set_list,
                only: [:show, :edit, :update, :destroy, :search_data, :admin, :crop_images, :members, :update_entity, :remove_entity, :clear_cache, :add_entity, :find_entity, :delete, :interlocks, :companies, :government, :other_orgs, :references, :giving, :funding, :modifications, :new_entity_associations, :create_entity_associations]

  # permissions
  before_action :set_permissions,
                only: [:members, :interlocks, :giving, :funding, :references, :edit, :update, :destroy, :add_entity, :remove_entity, :update_entity, :new_entity_associations, :create_entity_associations]
  before_action :set_entity, only: :index
  before_action -> { check_access(:viewable) }, only: [:members, :interlocks, :giving, :funding, :references]
  before_action -> { check_access(:editable) }, only: [:add_entity, :remove_entity, :update_entity, :new_entity_associations, :create_entity_associations]
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

    @list.validate_reference(reference_params)

    if @list.valid?
      @list.save!
      @list.add_reference(reference_params)
      redirect_to @list, notice: 'List was successfully created.'
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /lists/1
  def update
    if @list.update(list_params)
      @list.clear_cache(request.host)
      redirect_to members_list_path(@list), notice: 'List was successfully updated.'
    else
      render action: 'edit'
    end
  end

  # DELETE /lists/1
  # def destroy
  #   @list.destroy
  #   redirect_to lists_url, notice: 'List was successfully destroyed.'
  # end

  # GET /lists/:id/associations/entities
  def new_entity_associations; end

  # POST /lists/:id/associations/entities
  # only handles json
  def create_entity_associations

    payload = create_entity_associations_payload
    return render json: ERRORS[:entity_associations_bad_format], status: 400 unless payload

    reference = @list.add_entities(payload['entity_ids']).save_with_reference(payload['reference_attrs'])
    return render json: ERRORS[:entity_associations_invalid_reference], status: 400 unless reference

    render json: Api.as_api_json(@list.list_entities.to_a).merge('included' => Array.wrap(reference.api_data)),
           status: 200
  end

  def destroy
    #check_permission 'admin'

    @list.soft_delete
    redirect_to lists_path, notice: 'List was successfully destroyed.'
  end

  def admin
  end

  def crop_images
    check_permission 'importer'
    entity_ids = @list.entities.joins(:images).where(image: { is_featured: true }).group("entity.id").order("image.updated_at ASC").pluck(:id)
    set_entity_queue(:crop_images, entity_ids, @list.id)
    next_entity_id = next_entity_in_queue(:crop_images)
    image_id = Image.where(entity_id: next_entity_id, is_featured: true).first
    redirect_to crop_image_path(id: image_id)
  end

  def members
    @table = ListDatatable.new(@list)
    @table.generate_data

    @datatable_config = {
      update_path: update_entity_list_path(@table.list),
      include_context_col: @table.list.custom_field_name.present?,
      context_field_name: @table.context_field_name,
      editable: @permissions[:editable],
      ranked_table: @table.ranked?
    }
  end

  def clear_cache
    @list.clear_cache(request.host)
    render json: { status: 'success' }
  end

  def update_entity
    if data = params[:data]
      list_entity = ListEntity.find(data[:list_entity_id])
      list_entity.rank = data[:rank]
      if list_entity.list.custom_field_name.present?
        list_entity.custom_field = (data[:context].present? ? data[:context] : nil)
      end
      list_entity.save
      list_entity.list.clear_cache(request.host)
      table = ListDatatable.new(@list)
      render json: { row: table.list_entity_data(list_entity, data[:interlock_ids], data[:list_interlock_ids]) }
    else
      render json: {}, status: 404
    end
  end

  def remove_entity
    ListEntity.remove_from_list!(params[:list_entity_id].to_i, current_user: current_user)
    redirect_to members_list_path(@list)
  end

  def add_entity
    ListEntity.add_to_list!(list_id: @list.id,
                            entity_id: params[:entity_id],
                            current_user: current_user)
    redirect_to members_list_path(@list)
  end

  def interlocks
    interlocks_query
  end

  def companies
    @companies = interlocks_results(
      category_ids: [Relationship::POSITION_CATEGORY, Relationship::MEMBERSHIP_CATEGORY],
      order: 2,
      degree1_ext: 'Person',
      degree2_type: 'Business'
    )
  end

  def government
    @govt_bodies = interlocks_results(
      category_ids: [Relationship::POSITION_CATEGORY, Relationship::MEMBERSHIP_CATEGORY],
      order: 2,
      degree1_ext: 'Person',
      degree2_type: 'GovernmentBody'
    )
  end

  def other_orgs
    @others = interlocks_results(
      category_ids: [Relationship::POSITION_CATEGORY, Relationship::MEMBERSHIP_CATEGORY],
      order: 2,
      degree1_ext: 'Person',
      exclude_degree2_types: ['Business', 'GovernmentBody']
    )
  end

  def references
  end

  def giving
    @recipients = interlocks_results(
      category_ids: [Relationship::DONATION_CATEGORY],
      order: 2,
      degree1_ext: 'Person',
      sort: :amount
    )
  end

  def funding
    @donors = interlocks_results(
      category_ids: [Relationship::DONATION_CATEGORY],
      order: 1,
      degree1_ext: 'Person',
      sort: :amount
    )
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
  def list_params
    params.require(:list).permit(:name, :description, :is_ranked, :is_admin, :is_featured, :is_private, :custom_field_name, :short_description, :access)
  end

  def reference_params
    params.require(:ref).permit(:url, :name)
  end

  def create_entity_associations_payload
    payload = params.require('data').map { |x| x.permit('type', 'id', { 'attributes' => ['url', 'name'] }) }
    {
      'entity_ids'      => payload.select { |x| x['type'] == 'entities' }.map { |x| x['id'] },
      'reference_attrs' => payload.select { |x| x['type'] == 'references' }.map { |x| x['attributes'] }.first
    }
  rescue ActionController::ParameterMissing, ActiveRecord::RecordInvalid
    nil
  end

  def interlocks_query
    # get people in the list
    entity_ids = @list.entities.people.map(&:id)

    # get entities related by position or membership
    select = "e.*, COUNT(DISTINCT r.entity1_id) num, GROUP_CONCAT(DISTINCT r.entity1_id) degree1_ids, GROUP_CONCAT(DISTINCT ed.name) types"
    from = "relationship r LEFT JOIN entity e ON (e.id = r.entity2_id) LEFT JOIN extension_record er ON (er.entity_id = e.id) LEFT JOIN extension_definition ed ON (ed.id = er.definition_id)"
    where = "r.entity1_id IN (#{entity_ids.join(',')}) AND r.category_id IN (#{Relationship::POSITION_CATEGORY}, #{Relationship::MEMBERSHIP_CATEGORY}) AND r.is_deleted = 0"
    sql = "SELECT #{select} FROM #{from} WHERE #{where} GROUP BY r.entity2_id ORDER BY num DESC"
    db = ApplicationRecord.connection
    orgs = db.select_all(sql).to_hash

    # filter entities by type
    @companies = orgs.select { |org| org['types'].split(',').include?('Business') }
    @govt_bodies = orgs.select { |org| org['types'].split(',').include?('GovernmentBody') }
    @others = orgs.select { |org| (org['types'].split(',') & ['Business', 'GovernmentBody']).empty? }
  end

  def interlocks_results(options)
    @page = params.fetch(:page, 1)
    num = params.fetch(:num, 20)
    results = @list     .interlocks(options).page(@page).per(num)
    count = @list.interlocks_count(options)
    Kaminari.paginate_array(results.to_a, total_count: count).page(@page).per(num)
  end

  def set_permissions
    @permissions = current_user ?
                     current_user.permissions.list_permissions(@list) :
                     Permissions.anon_list_permissions(@list)
  end

  def check_access(permission)
    raise Exceptions::PermissionError unless @permissions[permission]
  end

  def after_tags_redirect_url(list)
    edit_list_url(list)
  end

  def check_tagable_access(list)
    unless current_user.permissions.list_permissions(list)[:configurable]
      raise Exceptions::PermissionError
    end
  end

  def permitted_scope
    if params[:editable] == 'true'
      List.editable(current_user)
    else
      List.viewable(current_user)
    end
  end

  def available_scope
    return permitted_scope unless @entity

    permitted_scope.where(id: @entity.lists.pluck(:id))
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
