class CampaignsController < ApplicationController
  before_action :set_campaign, only: [:show, :edit, :update, :destroy]

  # GET /campaigns
  def index
    @campaigns = Campaign.all
  end

  # GET /campaigns/1
  def show
  end

  # GET /campaigns/new
  def new
    @campaign = Campaign.new
  end

  # GET /campaigns/1/edit
  def edit
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

  private
    def add_logo
      @campaign.logo = params[:campaign][:logo] unless params[:campaign][:logo].nil?
    end

    def add_cover
      @campaign.cover = params[:campaign][:cover] unless params[:campaign][:cover].nil?
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_campaign
      @campaign = Campaign.find_by_slug(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def campaign_params
      params.require(:campaign).permit(:name, :slug, :tagline, :description, :logo, :cover, :findings, :howto)
    end
end
