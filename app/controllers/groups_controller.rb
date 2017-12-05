class GroupsController < ApplicationController
  before_action :set_group, only: [
    :show, :edit, :update, :destroy, :edits, :lists, :feature_list, :remove_list, :unfeature_list, 
    :new_list, :add_list, :join, :leave, :users, :promote_user, :demote_user, :remove_user, :admin, :entities,
    :clear_cache, :edit_advanced, :edit_findings, :edit_howto
  ]
  before_filter :authenticate_user!, except: [:show, :index, :search]

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
    @groups = Group.public_scope
      .select("groups.*, COUNT(DISTINCT(group_users.user_id)) AS user_count")
      .joins(:group_users)
      .group("groups.id")
      .order("user_count DESC")
      .page(params[:page]).per(20)
  end

  # GET /groups/1
  def show
    not_found if @group.blank?
    must_belong_to_private_group

    @recent_updates = @group.entities.includes(last_user: :user).order("updated_at DESC").limit(10)

    if user_signed_in? and current_user.in_group?(@group)
      @watched_entities = @group.featured_entities.order("ls_list_entity.created_at DESC").limit(5)
      @group_lists = @group.group_lists.order("is_featured DESC").joins(:list).where("ls_list.is_deleted" => false)
      @group_users = @group.group_users.joins(:user).order("users.username ASC")
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
    current_user_must_be_group_admin unless current_user.has_legacy_permission("admin")
  end

  def edit_advanced
    check_permission "admin"    
  end

  def edit_findings
    current_user_must_be_group_admin unless current_user.has_legacy_permission("admin")
  end

  def edit_howto
    current_user_must_be_group_admin unless current_user.has_legacy_permission("admin")
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
    current_user_must_be_group_admin unless current_user.has_legacy_permission("admin")
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

  def edits
    current_user_must_belong_to_group
    @recent_updates = @group.entities.includes(last_user: :user).order("updated_at DESC").page(params[:page]).per(20)
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
    current_user_must_belong_to_group
    @lists = nil
    @lists = List.where(List.arel_table[:name].matches("%#{params[:list_search]}%")) if params[:list_search].present?
  end

  def add_list
    current_user_must_belong_to_group
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
    current_user_must_be_group_admin unless current_user.has_legacy_permission("admin")
    check_permission "admin"
    @group_users = @group.group_users.joins(:user).order("users.username ASC").page(params[:page]).per(50)
  end

  def promote_user
    current_user_must_be_group_admin unless current_user.has_legacy_permission("admin")
    gu = GroupUser.where(group_id: @group.id, user_id: params[:user_id]).first
    throw "user isn't in the group" if gu.nil?
    gu.is_admin = true
    gu.save
    redirect_to users_group_path(@group)
  end

  def demote_user
    current_user_must_be_group_admin unless current_user.has_legacy_permission("admin")
    gu = GroupUser.where(group_id: @group.id, user_id: params[:user_id]).first
    throw "user isn't in the group" if gu.nil?
    gu.is_admin = false
    gu.save
    redirect_to users_group_path(@group)
  end

  def remove_user
    current_user_must_be_group_admin unless current_user.has_legacy_permission("admin")
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

  def clear_cache
    check_permission "admin"
    @group.touch
    redirect_to admin_group_path, notice: "Cache was successfully cleared."
  end

  def request_new
    @campaign = Campaign.find(params[:campaign_id]) if params[:campaign_id].present?
  end

  def send_request
    @campaign = Campaign.find_by(id: params[:campaign_id])
    gr = GroupRequest.new(params[:name], params[:description], @campaign)

    if gr.valid?
      GroupRequestMailer.notify_admin(gr, current_user).deliver
      redirect_to request_sent_groups_path
    else
      @errors = gr.errors
      render "request_new"
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_group
      @group = Group.find_by_slug(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def group_params
      params.require(:group).permit(
        :name, :slug, :tagline, :description, :logo, :remove_logo, :logo_cache, :logo_credit, 
        :is_private, :findings, :howto, :campaign_id
      )
    end
end
