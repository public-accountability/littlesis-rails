class ListsController < ApplicationController
  before_filter :authenticate_user!, except: [:index, :show, :relationships, :members, :clear_cache, :interlocks, :companies, :government, :other_orgs, :references, :giving, :funding]
  before_action :set_list, only: [:show, :edit, :update, :destroy, :relationships, :match_donations, :search_data, :admin, :find_articles, :crop_images, :street_views, :members, :create_map, :update_entity, :remove_entity, :clear_cache, :add_entity, :find_entity, :delete, :interlocks, :companies, :government, :other_orgs, :references, :giving, :funding, :modifications]

  def self.get_lists(page)
    List
      .select("ls_list.*, COUNT(DISTINCT(ls_list_entity.entity_id)) AS entity_count")
      .joins(:list_entities)
      .where(is_network: false, is_admin: false)
      .group("ls_list.id")
      .order("entity_count DESC")
      .page(page).per(20)
  end

  # GET /lists
  def index
    lists = self.class.get_lists(params[:page])

    if current_user.present?
      @lists = lists.where('ls_list.is_private = ? OR ls_list.creator_user_id = ?', false, current_user.id)
    else
      @lists = lists.public_scope
    end

    if params[:q].present?
      is_admin = (current_user and current_user.has_legacy_permission('admin')) ? [0, 1] : 0
      list_ids = List.search(
        Riddle::Query.escape(params[:q]),
        with: { is_deleted: 0, is_admin: is_admin, is_network: 0 }
      ).map(&:id)
      @lists = @lists.where(id: list_ids).reorder('')
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
    check_permission 'admin' if @list.is_admin || @list.is_network
  end

  # POST /lists
  def create
    @list = List.new(list_params)
    @list.creator_user_id = current_user.id
    @list.last_user_id = current_user.sf_guard_user_id

    if params[:ref][:source].blank?
      @list.errors.add_on_blank(:name)
      @list.errors[:base] << "A source URL is required"
      render action: 'new' and return
    end
    
    if @list.save
      @list.add_reference(params[:ref][:source], params[:ref][:name])
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
  def destroy
    @list.destroy
    redirect_to lists_url, notice: 'List was successfully destroyed.'
  end

  def relationships
  end

  def match_donations
    check_permission 'bulker'
    page = params.fetch(:page, 1)
    num = params.fetch(:num, 100)
    @entities = @list.entities_with_couples.people
                .joins(:os_entity_transactions)
                .includes(:links, :addresses)
                .joins("LEFT JOIN address ON (address.entity_id = entity.id)")
                .select("entity.*, COUNT(os_entity_transaction.id) AS num_matches, MAX(os_entity_transaction.reviewed_at) AS last_reviewed")
                .group("entity.id").having('COUNT(os_entity_transaction.id) > 0').order("last_reviewed ASC, num_matches DESC").page(page).per(num)
  end

  def admin
  end

  def find_articles
    check_permission 'importer'    
    entity_ids = @list.entities_with_couples.joins("LEFT JOIN article_entities ON (article_entities.entity_id = entity.id)").where(article_entities: { id: nil }).pluck(:id)
    set_entity_queue(:find_articles, entity_ids, @list.id)
    next_entity_id = next_entity_in_queue(:find_articles)
    redirect_to find_articles_entity_path(id: next_entity_id)
  end

  def crop_images
    check_permission 'importer'
    entity_ids = @list.entities.joins(:images).where(image: { is_featured: true }).group("entity.id").order("image.updated_at ASC").pluck(:id)
    set_entity_queue(:crop_images, entity_ids, @list.id)
    next_entity_id = next_entity_in_queue(:crop_images)
    image_id = Image.where(entity_id: next_entity_id, is_featured: true).first
    redirect_to crop_image_path(id: image_id)
  end

  def street_views
    check_permission 'editor'
    entity_ids = @list.entities_with_couples.pluck(:id).uniq
    @images = Image.joins(entity: :addresses).where(entity_id: entity_ids).where("image.caption LIKE 'street view:%'").order(:created_at)
    render layout: false
  end

  def members
    @table = ListDatatable.new(@list)
    @table.generate_data
    @editable = (current_user and current_user.has_legacy_permission('lister'))
    @admin = (current_user and current_user.has_legacy_permission('admin'))
  end

  def create_map
    map = NetworkMap.create_from_entities(@list.name, current_user.id, @list.entities_with_couples.pluck(:id))
    redirect_to edit_map_url(map, wheel: true)
  end

  def update_entity
    check_permission 'lister'
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
    check_permission 'admin'
    ListEntity.find(params[:list_entity_id]).destroy
    @list.clear_cache(request.host)
    redirect_to members_list_path(@list)        
  end

  def clear_cache
    @list.clear_cache(request.host)
    render json: { status: 'success' }
  end

  def add_entity
    check_permission 'lister'
    le = ListEntity.find_or_create_by(list_id: @list.id, entity_id: params[:entity_id])
    @list.clear_cache(request.host)
    le.entity.clear_cache(request.host)
    redirect_to members_list_path(@list)
  end

  def delete
    check_permission 'admin'
    @list.soft_delete
    redirect_to lists_path
  end

  def interlocks
    # get people in the list
    entity_ids = @list.entities.people.map(&:id)

    # get entities related by position or membership
    select = "e.*, COUNT(DISTINCT r.entity1_id) num, GROUP_CONCAT(DISTINCT r.entity1_id) degree1_ids, GROUP_CONCAT(DISTINCT ed.name) types"
    from = "relationship r LEFT JOIN entity e ON (e.id = r.entity2_id) LEFT JOIN extension_record er ON (er.entity_id = e.id) LEFT JOIN extension_definition ed ON (ed.id = er.definition_id)"
    where = "r.entity1_id IN (#{entity_ids.join(',')}) AND r.category_id IN (#{Relationship::POSITION_CATEGORY}, #{Relationship::MEMBERSHIP_CATEGORY}) AND r.is_deleted = 0"
    sql = "SELECT #{select} FROM #{from} WHERE #{where} GROUP BY r.entity2_id ORDER BY num DESC"
    db = ActiveRecord::Base.connection
    orgs = db.select_all(sql).to_hash

    # filter entities by type
    @companies = orgs.select { |org| org['types'].split(',').include?('Business') }
    @govt_bodies = orgs.select { |org| org['types'].split(',').include?('GovernmentBody') }
    @others = orgs.select { |org| (org['types'].split(',') & ['Business', 'GovernmentBody']).empty? }
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
    @versions = Kaminari.paginate_array(@list.versions.reverse).page(params[:page]).per(5)
    @all_entities = ListEntity.unscoped.where(list_id: @list.id).order(id: :desc).page(params[:page]).per(10)
  end
  

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_list
      @list = List.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def list_params
      params.require(:list).permit(:name, :description, :is_ranked, :is_admin, :is_featured, :is_private, :custom_field_name)
    end

    def interlocks_results(options)
      @page = params.fetch(:page, 1)
      num = params.fetch(:num, 20)
      results = @list     .interlocks(options).page(@page).per(num)
      count = @list.interlocks_count(options)
      Kaminari.paginate_array(results.to_a, total_count: count).page(@page).per(num)
    end
end
