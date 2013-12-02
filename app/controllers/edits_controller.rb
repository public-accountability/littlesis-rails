class EditsController < ApplicationController
	before_action :auth

	def index
		@edits = Entity
      .includes(last_user: { sf_guard_user: :sf_guard_user_profile })
      .order("updated_at DESC").page(params[:page]).per(20)
	end
end
