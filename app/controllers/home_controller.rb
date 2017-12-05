class HomeController < ApplicationController
  before_action :authenticate_user!, except: [:dismiss, :sign_in_as, :index, :contact, :flag, :token, :error]

  # [list_id, 'title' ]
  DOTS_CONNECTED_LISTS = [
    [41, 'Paid for politicians'],
    [88, 'Corporate fat cats'],
    [102, 'Revolving door lobbyists'],
    [114, 'Secretive Super PACs'],
    [34, 'Elite think tanks']
  ]

	def groups
    @groups = Group
      .select("groups.*, COUNT(DISTINCT(group_users.user_id)) AS user_count")
      .joins(:group_users)
      .group("groups.id")
      .where(id: current_user.group_ids)
      .order("user_count DESC")
      .page(params[:page]).per(20)
	end

  def dashboard
    @maps = current_user.network_maps.order("created_at DESC, id DESC")
    @groups = current_user.groups.order(:name)
    @lists = current_user.lists.order("created_at DESC, id DESC")
    @recent_updates = current_user.edited_entities.includes(last_user: :user).order("updated_at DESC").limit(10)
  end

  # Sends CSRF token to browser extension
  def token
    if user_signed_in?
      render :inline => "<%= csrf_meta_tags %>"
    elsif Rails.env.development?
      render :inline => '<meta name="csrf-param" content="authenticity_token" /><meta name="csrf-token" content="CSRF-TOKEN-FOR-TESTING" />'
    else
      head :unauthorized
    end
  end

  def extension_path
    render :inline => "https://dfl6orqdcqt4f.cloudfront.net/assets/#{Rails.application.assets.find_asset('extension.js').digest_path}"
    render :inline => "<%= csrf_meta_tags %>"
  end

  def dismiss
    dismiss_alert(params[:id])
    render json: { id: params[:id] }
  end

  def maps
    @maps = current_user.network_maps.order("created_at DESC").page(params[:page]).per(20)
    @header = 'My Network Maps'
    render 'maps/index'
  end

  def lists
    @lists = current_user.lists
      .select("ls_list.*, COUNT(DISTINCT(ls_list_entity.entity_id)) AS entity_count")
      .joins(:list_entities)
      .where(is_network: false, is_admin: false)
      .group("ls_list.id")
      .order("entity_count DESC")
      .page(params[:page]).per(20)
      
    render 'lists/index'
  end

  def index
    redirect_to_dashboard_if_signed_in unless request.env['PATH_INFO'] == '/home'
    @dots_connected = dots_connected
    @carousel_entities = carousel_entities
    @stats = ExtensionRecord.data_summary
  end

  def contact
    if request.post?
      if contact_params[:name].blank?
        flash.now[:alert] = "Please enter in your name"
        @message = params[:message]
      elsif contact_params[:email].blank?
        flash.now[:alert] = 'Please enter in your email'
        @message = params[:message]
      elsif contact_params[:message].blank?
        flash.now[:alert] = "Don't forget to write a message!"
        @name = params[:name]
      else
        NotificationMailer.contact_email(params).deliver_later # send_mail
        flash.now[:notice] = 'Your message has been sent. Thank you!'
      end
    end
  end

  def flag
    if request.post?
      if flag_params[:email].blank?
        flash.now[:alert] = 'Please enter in your email'
        @message = flag_params[:message]
        @name = flag_params[:name]
        @referrer = flag_params[:url]
      elsif flag_params[:message].blank?
        flash.now[:alert] = "Don't forget to write a message!"
        @name = flag_params[:name]
        @referrer = flag_params[:url]
      else
        NotificationMailer.flag_email(flag_params.to_h).deliver_later
        flash.now[:notice] = 'Your message has been sent. Thank you!'
      end
    else
      @referrer = request.referrer
    end
  end

  def error
    raise StandardError
  end
  
  private

  def redirect_to_dashboard_if_signed_in
    if user_signed_in?
      return redirect_to home_dashboard_path
    end
  end

  def carousel_entities
    Rails.cache.fetch('home_controller_index_carousel_entities', expires_in: 2.hours) do
      List.find(APP_CONFIG.fetch('carousel_list_id')).entities.to_a
    end
  end

  def dots_connected
    Rails.cache.fetch('dots_connected_count', expires_in: 2.hours) do
      (Person.count + Org.count).to_s.split('')
    end
  end

  def contact_params
    params.permit(:email, :subject, :name, :message)
  end

  def flag_params
    params.permit(:email, :url, :name, :message)
  end
end
