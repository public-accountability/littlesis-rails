class EditsController < ApplicationController
  before_action :authenticate_user!

  def index
    @edits = Entity
             .includes(last_user: :user)
             .order("updated_at DESC").page(params[:page]).per(20)
  end
end
