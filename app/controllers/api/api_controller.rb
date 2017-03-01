module Api
  class ApiController < ActionController::Base
    protect_from_forgery with: :null_session
    
    def index
      render json: {'test' => 123}
    end
  end
end
