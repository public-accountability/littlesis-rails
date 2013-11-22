class HomeController < ApplicationController
	before_filter :auth

	def notes
    @user = User.includes(:notes, notes: :recipients).find_by_username(current_user.username)

    if params[:show_replies].present? and params[:show_replies] == "1"
    	@notes = @user.notes_with_replies.order("created_at DESC").page(params[:page]).per(20)
    else
    	@notes = @user.notes.order("created_at DESC").page(params[:page]).per(20)
    end
	end

	def groups
    @groups = Group
      .select("groups.*, COUNT(DISTINCT(group_users.user_id)) AS user_count")
      .joins(:group_users)
      .joins(:sf_guard_group)
      .group("groups.id")
      .where(sf_guard_group: { is_working: true })
      .where(id: current_user.group_ids)
      .order("user_count DESC")
      .page(params[:page]).per(20)
	end
end
