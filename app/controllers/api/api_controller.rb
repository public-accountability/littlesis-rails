module Api
  class ApiController < ActionController::Base
    protect_from_forgery with: :null_session

    rescue_from ActiveRecord::RecordNotFound do
      render json: ApiUtils::Response.error(:RECORD_NOT_FOUND)
    end

    rescue_from Entity::EntityDeleted do
      render json: ApiUtils::Response.error(:RECORD_DELETED)
    end

    def index
      render json: {'test' => 123}
    end
    
  end
end
