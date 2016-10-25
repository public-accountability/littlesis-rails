class HomeController < ApplicationController
  before_action :authenticate_user!, except: [:dismiss, :sign_in_as, :index]
  # before_filter :auth

  # [list_id, 'title' ]
  DOTS_CONNECTED_LISTS = [
    [41, 'Paid for politicians'],
    [88, 'Corporate fat cats'],
    [102, 'Revolving door lobbyists'],
    [114, 'Secretive Super PACs'],
    [34, 'Elite think tanks']
  ]

  CAROUSEL_LIST_ID = 404 # The id of the list that contains the entities for the carousel

	def notes
    @user = User.includes(:notes, notes: :recipients).find_by_username(current_user.username)

    q = Riddle::Query.escape(params[:q]) if params[:q].present?

    if params[:show_replies] == "1"
    	query = Note.search(q, order: "created_at DESC", with: { visible_to_user_ids: [current_user.id] })
    else
    	query = Note.search(q, order: "created_at DESC", with: { user_id: current_user.id })
    end

    @notes = query.page(params[:page]).per(20)

    prepopulate_note_from_params
	end

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
    @groups = current_user.groups.includes(:campaign).order(:name)
    @recent_updates = current_user.edited_entities.includes(last_user: :user).order("updated_at DESC").limit(10)
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

  def index
    @dots_connected = (Person.count + Org.count).to_s.split('')
    @carousel_entities = List.find(404).entities.to_a
    @stats = stats
  end

  private


  # Returns nested array 
  # [ [ count, display name] ]
  def stats
    Rails.cache.fetch('data_summary_stats', expires_in: 1.hour) do 
      ExtensionRecord.stats.unshift( [Reference.count, 'Citation'] , [ Relationship.count, 'Relationship'  ]  )
    end
  end

end
