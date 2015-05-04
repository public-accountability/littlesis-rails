class ListsController < ApplicationController
  before_filter :auth, except: [:relationships, :members, :clear_cache]
  before_action :set_list, only: [:show, :edit, :update, :destroy, :relationships, :match_donations, :search_data, :admin, :find_articles, :crop_images, :street_views, :members, :create_map, :update_entity, :remove_entity, :clear_cache]

  # GET /lists
  def index
    @lists = List
      .select("ls_list.*, COUNT(DISTINCT(ls_list_entity.entity_id)) AS entity_count")
      .joins(:list_entities)
      .where(is_network: false)
      .group("ls_list.id")
      .order("entity_count DESC")
      .page(params[:page]).per(20)
  end

  # GET /lists/1
  def show
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

    if @list.save
      redirect_to @list, notice: 'List was successfully created.'
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /lists/1
  def update
    if @list.update(list_params)
      redirect_to @list, notice: 'List was successfully updated.'
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
      list_entity.list.clear_cache
      table = ListDatatable.new(@list)
      render json: { row: table.list_entity_data(list_entity, data[:interlock_ids], data[:list_interlock_ids]) }
    else
      render json: {}, status: 404
    end
  end

  def remove_entity
    check_permission 'admin'
    ListEntity.find(params[:list_entity_id]).destroy
    @list.clear_cache
    redirect_to members_list_path(@list)        
  end

  def clear_cache
    @list.clear_cache
    render json: { status: 'success' }
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_list
      @list = List.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def list_params
      params[:list]
    end
end
