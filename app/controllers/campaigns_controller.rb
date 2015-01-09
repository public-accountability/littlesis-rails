class CampaignsController < ApplicationController
  before_action :set_campaign, only: [:show, :edit, :edit_findings, :edit_guide, :update, :destroy, :groups, 
    :admin, :clear_cache, :entities, :signup, :subscribe, :thankyou]

  # GET /campaigns
  def index
    check_permission "admin"
    @campaigns = Campaign.all
  end

  # GET /campaigns/1
  def show
    @groups = @campaign.groups.public_scope
      .select("groups.*, COUNT(DISTINCT(group_users.user_id)) AS user_count")
      .joins(:group_users)
      .group("groups.id")
      .order("user_count DESC")
      .limit(3)

    @recent_updates = @campaign.entities.includes(last_user: :user).order("updated_at DESC").limit(10)
    @watched_entities = @campaign.featured_entities.limit(10)
  end

  # GET /campaigns/new
  def new
    check_permission "admin"
    @campaign = Campaign.new
  end

  # GET /campaigns/1/edit
  def edit
    check_permission "admin"
  end

  def edit_findings
    check_permission "admin"
  end

  def edit_guide
    check_permission "admin"
  end

  # POST /campaigns
  def create
    @campaign = Campaign.new(campaign_params)
    add_logo
    add_cover

    if @campaign.save
      redirect_to @campaign, notice: 'Campaign was successfully created.'
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /campaigns/1
  def update
    @campaign.assign_attributes(campaign_params)
    add_logo
    add_cover

    if @campaign.save
      redirect_to @campaign, notice: 'Campaign was successfully updated.'
    else
      render action: 'edit'
    end
  end

  # DELETE /campaigns/1
  def destroy
    @campaign.destroy
    redirect_to campaigns_url, notice: 'Campaign was successfully destroyed.'
  end

  def search_groups
    data = []
    groups = Group.search Riddle::Query.escape(params[:q]), per_page: 10, match_mode: :extended
    data = groups.collect { |g| { value: g.name, name: g.name, id: g.id, slug: g.slug } }
    render json: data    
  end

  def groups
    # @groups = @campaign.groups.working.order(:name).page(params[:page]).per(20)

    @groups = @campaign.groups.public
      .select("groups.*, COUNT(DISTINCT(group_users.user_id)) AS user_count")
      .joins(:group_users)
      .group("groups.id")
      .order("groups.name")
      .page(params[:page]).per(20)
  end

  def entities
    @entities = @campaign.featured_entities.order("ls_list_entity.created_at DESC").page(params[:page]).per(50)
  end

  def admin
    check_permission "admin"
  end

  def clear_cache
    check_permission "admin"
    @campaign.clear_cache
    redirect_to admin_campaign_path(@campaign), notice: "Cache was successfully cleared."
  end

  def signup
    not_found unless @campaign.student_debt?
  end

  def subscribe
    not_found unless @campaign.student_debt?

    list_id = 1504112429

    signup = StudentDebtCampaignSignup.from_params(params)
    share_contact_info = params[:share_contact_info] == "1" ? 1 : 0

    if signup.valid?
      member_data = [
        {'name' => 'email_address', 'value' => signup.email},
        {'name' => 'first_name', 'value' => signup.first_name},
        {'name' => 'last_name', 'value' => signup.last_name},
        {'name' => 'school', 'value' => signup.school},
        {'name' => 'share_contact_info', 'value' => share_contact_info}
      ]

      vr = VerticalResponse.new
      member = vr.add_list_member(list_id, member_data)

      StudentDebtMailer.welcome(signup).deliver

      redirect_to thankyou_campaign_path(@campaign)
    else
      @errors = signup.errors
      render 'signup'
    end
  end

  def thankyou

  end

  private
    def add_logo
      @campaign.logo = params[:campaign][:logo] unless params[:campaign][:logo].nil?
    end

    def add_cover
      @campaign.cover = params[:campaign][:cover] unless params[:campaign][:cover].nil?
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_campaign
      @campaign = Campaign.find_by_slug!(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def campaign_params
      params.require(:campaign).permit(
        :name, :slug, :tagline, :description, :logo, :remove_logo, :logo_cache, 
        :logo_credit, :findings, :howto, :custom_html
      )
    end
end
