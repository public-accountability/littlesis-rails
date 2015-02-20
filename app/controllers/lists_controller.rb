class ListsController < ApplicationController
  before_action :set_list, only: [:show, :edit, :update, :destroy, :relationships, :match_donations, :search_data]

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
    page = params.fetch(:page, 1)
    num = params.fetch(:num, 100)
    @entities = @list.entities.people
                .joins(:os_entity_transactions)
                .includes(:links, :addresses)
                .joins("LEFT JOIN address ON (address.entity_id = entity.id)")
                .select("entity.*, COUNT(os_entity_transaction.id) AS num_matches, MAX(os_entity_transaction.reviewed_at) AS last_reviewed")
                .group("entity.id").having('COUNT(os_entity_transaction.id) > 0').order("last_reviewed ASC, num_matches DESC").page(page).per(num)
  end

  def search_data
    respond_to do |format|
      format.json {
        render json: @list.entities.includes(:aliases).map { |e| { id: e.id, name: e.name, oneliner: e.blurb, aliases: e.aliases.map { |a| a.name } } }
      }
    end
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
