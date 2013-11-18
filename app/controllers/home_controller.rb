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
end
