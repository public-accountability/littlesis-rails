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

  def dashboard
    @show_helper = false

    unless [1, 2, 201, 21, 1399, 188, 191, 1606, 2129, 1842].include? current_user.sf_guard_user_id
      # this is really hacky but works for now
      sql = "SELECT COUNT(*) FROM modification WHERE user_id = #{current_user.sf_guard_user_id}"
      count = ActiveRecord::Base.connection.select_value(sql)      
      @show_helper = count < 500
    end

    @notes = Note.visible_to_user(current_user).limit(20).readonly(false)
    @groups = current_user.groups.order(:name)
    @recent_updates = Entity
      .includes(last_user: { sf_guard_user: :sf_guard_user_profile })
      .where(last_user_id: current_user.sf_guard_user_id)
      .order("updated_at DESC").limit(10)
  end
end
