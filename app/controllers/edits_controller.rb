class EditsController < ApplicationController
	before_action :auth

	def index
		@edits = Entity
      .includes(last_user: :user)
      .order("updated_at DESC").page(params[:page]).per(20)
	end
end
