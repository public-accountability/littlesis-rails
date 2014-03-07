class HomeController < ApplicationController
	before_filter :auth, except: [:dismiss, :sign_in_as]

	def notes
    @user = User.includes(:notes, notes: :recipients).find_by_username(current_user.username)

    q = Riddle::Query.escape(params[:q]) if params[:q].present?

    if params[:show_replies].present? and params[:show_replies] == "1"
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
    Note.convert_all_new_legacy
    @notes = Note.visible_to_user(current_user).limit(20).readonly(false)
    @groups = current_user.groups.includes(:campaign).order(:name)
    @campaigns = @groups.collect(&:campaign).compact.uniq.sort_by { |campaign| campaign.name  }
    @recent_updates = current_user.edited_entities.includes(last_user: :user).order("updated_at DESC").limit(10)
  end

  def dismiss
    dismiss_alert(params[:id])
    render json: { id: params[:id] }
  end

  # EXTREMELY TEMPORARY AND SHOULD BE REMOVED
  def sign_in_as
    user = User.find_by(username: params[:username])
    redirect_to :status => 404 unless user.present?
    sign_in user
    redirect_to home_dashboard_path
  end
end
