class GroupsController < ApplicationController
  before_action :set_group, only: [
    :show, :edit, :update, :destroy, :notes, :edits, :lists, :feature_list, :remove_list, :unfeature_list, 
    :new_list, :add_list, :join, :leave, :users, :promote_user, :demote_user, :remove_user, :admin, :entities
  ]
  before_filter :auth, except: [:show, :index, :search]

  def must_belong_to_private_group
    current_user_must_belong_to_group if @group.private?
  end

  def current_user_must_belong_to_group
    raise Exceptions::PermissionError unless current_user.present? and current_user.in_group?(@group)
  end

  def current_user_must_be_group_admin
    raise Exceptions::PermissionError unless current_user.present? and current_user.admin_in_group?(@group)
  end

  # GET /groups
  def index
    @groups = Group.public
      .select("groups.*, COUNT(DISTINCT(group_users.user_id)) AS user_count")
      .joins(:group_users)
      .group("groups.id")
      .having("user_count > 0")
      .order("user_count DESC")
      .page(params[:page]).per(20)
  end

  # GET /groups/1
  def show
    must_belong_to_private_group
    @recent_updates = Entity.includes(last_user: { sf_guard_user: :sf_guard_user_profile })
                            .where(last_user_id: @group.sf_guard_user_ids)
                            .order("updated_at DESC").limit(10)
    if user_signed_in? and current_user.in_group?(@group)
      @notes = @group.notes.public.order("created_at DESC").limit(10)
      @watched_entities = @group.featured_entities.order("ls_list_entity.created_at DESC").limit(5)
    else
      @carousel_entities = @group.featured_entities.limit(20)
    end
  end

  # GET /groups/new
  def new
    check_permission "admin"
    @group = Group.new
  end

  # GET /groups/1/edit
  def edit
    check_permission "admin"    
  end

  # POST /groups
  def create
    check_permission "admin"    
    @group = Group.new(group_params)

    if @group.save
      redirect_to @group, notice: 'Group was successfully created.'
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /groups/1
  def update
    check_permission "admin"    
    if @group.update(group_params)
      redirect_to @group, notice: 'Group was successfully updated.'
    else
      render action: 'edit'
    end
  end

  # DELETE /groups/1
  def destroy
    check_permission "admin"    
    @group.destroy
    redirect_to groups_url, notice: 'Group was successfully destroyed.'
  end

  def notes
    current_user_must_belong_to_group

    if params[:q].present?
      @notes = Note.search(
        Riddle::Query.escape(params[:q]), 
        order: "created_at DESC", 
        with: { group_ids: [@group.id] }
      ).page(params[:page]).per(20)
    else
      @notes = @group.notes.order("updated_at DESC").page(params[:page]).per(20)
    end
  end

  def edits
    current_user_must_belong_to_group
    @recent_updates = Entity
      .includes(last_user: { sf_guard_user: :sf_guard_user_profile })
      .where(last_user_id: @group.sf_guard_user_ids)
      .order("updated_at DESC").page(params[:page]).per(20)
  end

  def lists
    current_user_must_belong_to_group    
    @group_lists = @group.group_lists.order("is_featured DESC").joins(:list).where("ls_list.is_deleted" => false)
  end

  def feature_list
    current_user_must_be_group_admin
    gl = GroupList.find_by(group_id: @group.id, list_id: params[:list_id])
    gl.is_featured = true
    gl.save
    redirect_to lists_group_path(@group)
  end

  def unfeature_list
    current_user_must_be_group_admin
    gl = GroupList.find_by(group_id: @group.id, list_id: params[:list_id])
    gl.is_featured = false
    gl.save
    redirect_to lists_group_path(@group)
  end

  def remove_list
    current_user_must_be_group_admin
    @group.lists.destroy List.find(params[:list_id])
    redirect_to lists_group_path(@group)    
  end

  def new_list
    current_user_must_be_group_admin
    @lists = nil
    @lists = List.where(List.arel_table[:name].matches("%#{params[:list_search]}%")) if params[:list_search].present?
  end

  def add_list
    current_user_must_be_group_admin
    @group.lists << List.find(params[:list_id])
    redirect_to lists_group_path(@group)    
  end

  def join
    @group.users << current_user
    redirect_to @group
  end

  def leave
    @group.users.destroy(current_user)
    redirect_to @group.private? ? root_path : @group
  end

  def users
    check_permission "admin"
    @group_users = @group.group_users.joins(:user).order("users.username ASC").page(params[:page]).per(50)
  end

  def promote_user
    check_permission "admin"
    gu = GroupUser.where(group_id: @group.id, user_id: params[:user_id]).first
    throw "user isn't in the group" if gu.nil?
    gu.is_admin = true
    gu.save
    redirect_to users_group_path(@group)
  end

  def demote_user
    check_permission "admin"
    gu = GroupUser.where(group_id: @group.id, user_id: params[:user_id]).first
    throw "user isn't in the group" if gu.nil?
    gu.is_admin = false
    gu.save
    redirect_to users_group_path(@group)
  end

  def remove_user
    check_permission "admin"
    gu = GroupUser.where(group_id: @group.id, user_id: params[:user_id]).first
    throw "user isn't in the group" if gu.nil?
    gu.destroy
    redirect_to users_group_path(@group)
  end

  def admin
    check_permission "admin"
  end

  def entities
    current_user_must_belong_to_group    
    @entities = @group.featured_entities.order("ls_list_entity.created_at DESC").page(params[:page]).per(50)
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
        :campaign_id
      )
    end
end
