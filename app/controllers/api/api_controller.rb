# frozen_string_literal: true

module Api
  class ApiController < ActionController::Base
    PER_PAGE = 100
    protect_from_forgery with: :null_session

    unless Rails.env.development?
      before_action :api_authenticate!
      skip_before_action :api_authenticate!, only: [:index]
    end

    rescue_from ActiveRecord::RecordNotFound do
      render json: Api.error_json(:RECORD_NOT_FOUND), status: :not_found
    end

    rescue_from Exceptions::ModelIsDeletedError do
      render json: Api.error_json(:RECORD_DELETED), status: :gone
    end

    rescue_from Exceptions::InvalidRelationshipCategoryError do
      render json: Api.error_json(:INVALID_RELATIONSHIP_CATEGORY), status: :bad_request
    end

    rescue_from Exceptions::MissingApiTokenError do
      head :unauthorized
    end

    rescue_from Exceptions::PermissionError do
      head :forbidden
    end

    def index
      render 'api/index', layout: 'application'
    end

    def param_to_bool(val)
      ![nil, false, 0, '0', 'f', 'F', 'false', 'False', 'FALSE', 'off', 'OFF'].include?(val)
    end

    protected

    def api_authenticate!
      return if api_token.blank? && user_signed_in?

      verify_api_token!
    end

    def verify_api_token!
      raise Exceptions::MissingApiTokenError if api_token.blank?
      raise Exceptions::PermissionError unless ApiToken.valid_token?(api_token)
    end

    private

    def api_token
      request.headers['Littlesis-Api-Token']
    end
  end
end
