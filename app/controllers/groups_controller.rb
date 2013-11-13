class GroupsController < ApplicationController
  before_action :set_group, only: [
    :show, :edit, :update, :destroy, :notes, :edits, :lists, :feature_list, :remove_list, :unfeature_list, 
    :new_list, :add_list
  ]

  # GET /groups
  def index
    @groups = Group.all
  end

  # GET /groups/1
  def show
    @recent_updates = Entity.includes(last_user: { sf_guard_user: :sf_guard_user_profile })
                            .where(last_user_id: @group.sf_guard_user_ids)
                            .order("updated_at DESC").limit(10)
    if true or user_signed_in?
      @notes = @group.notes.order("updated_at DESC").limit(10)
    end
  end

  # GET /groups/new
  def new
    @group = Group.new
  end

  # GET /groups/1/edit
  def edit
  end

  # POST /groups
  def create
    @group = Group.new(group_params)

    if @group.save
      redirect_to @group, notice: 'Group was successfully created.'
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /groups/1
  def update
    if @group.update(group_params)
      redirect_to @group, notice: 'Group was successfully updated.'
    else
      render action: 'edit'
    end
  end

  # DELETE /groups/1
  def destroy
    @group.destroy
    redirect_to groups_url, notice: 'Group was successfully destroyed.'
  end

  def notes
    @notes = @group.notes.order("updated_at DESC").page(params[:page]).per(20)
  end

  def edits
    @recent_updates = Entity
      .includes(last_user: { sf_guard_user: :sf_guard_user_profile })
      .where(last_user_id: @group.sf_guard_user_ids)
      .order("updated_at DESC").page(params[:page]).per(20)
  end

  def lists
    @group_lists = @group.group_lists.order("is_featured DESC").joins(:list).where("ls_list.is_deleted" => false)
  end

  def feature_list
    gl = GroupList.find_by(group_id: @group.id, list_id: params[:list_id])
    gl.is_featured = true
    gl.save
    redirect_to lists_group_path(@group)
  end

  def unfeature_list
    gl = GroupList.find_by(group_id: @group.id, list_id: params[:list_id])
    gl.is_featured = false
    gl.save
    redirect_to lists_group_path(@group)
  end

  def remove_list
    @group.lists.destroy List.find(params[:list_id])
    redirect_to lists_group_path(@group)    
  end

  def new_list
    @lists = nil
    @lists = List.where(List.arel_table[:name].matches("%#{params[:list_search]}%")) if params[:list_search].present?
  end

  def add_list
    @group.lists << List.find(params[:list_id])
    redirect_to lists_group_path(@group)    
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_group
      @group = Group.find_by_slug(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def group_params
      params.require(:group).permit(
        :name, :slug, :tagline, :description, :logo, :cover, :is_private, :findings, :howto, :bootsy_image_gallery_id,
        :page, :list_id, :q
      )
    end
end
