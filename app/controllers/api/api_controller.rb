module Api
  class ApiController < ActionController::Base
    protect_from_forgery with: :null_session

    rescue_from ActiveRecord::RecordNotFound do
      render json: ApiUtils::Response.error(:RECORD_NOT_FOUND), status: :not_found
    end

    rescue_from Entity::EntityDeleted do
      render json: ApiUtils::Response.error(:RECORD_DELETED), status: :gone
    end

    def index
      render 'api/index', layout: 'application'
    end
  end
end


