# frozen_string_literal: true

module Lists
  class EntityAssociationsController < ApplicationController
    include ListPermissions

    ERRORS = ActiveSupport::HashWithIndifferentAccess.new(
      entity_associations_bad_format: {
        errors: [{ title: 'Could not add entities to list: improperly formatted request.' }]
      },
      entity_associations_invalid_reference: {
        errors: [{ title: 'Could not add entities to list: invalid reference.' }]
      }
    ).freeze

    before_action :authenticate_user!, only: :new
    before_action -> { current_uesr.role.include?(:create_list) }
    before_action :set_list

    before_action :set_permissions
    before_action -> { check_access(:editable) }

    before_action :set_payload, :set_document_attributes, only: :create

    def new
    end

    def create
      return if performed?

      @list
        .add_entities(@payload['entity_ids'])
        .add_reference(@document_attributes)
        .save!

      render json: json, status: :ok
    end

    private

    def set_list
      @list = List.find(params[:list_id])
    end

    def set_document_attributes
      @document_attributes = Document::DocumentAttributes.new(@payload['reference_attrs'])

      unless @document_attributes.valid?
        return render json: ERRORS[:entity_associations_invalid_reference], status: :bad_request
      end
    end

    def basic_payload
      @basic_payload ||= params.require('data')
        .map { |x| x.permit('type', 'id', { 'attributes' => %w[url name] }) }
    end

    def payload_reference_attrs
      basic_payload
        .select { |x| x['type'] == 'references' }
        .map { |x| x['attributes'] }
        .first
    end

    def payload_entity_ids
      basic_payload
        .select { |x| x['type'] == 'entities' }
        .map { |x| x['id'] }
    end

    def set_payload
      @payload ||= {
        'entity_ids' => payload_entity_ids,
        'reference_attrs' => payload_reference_attrs
      }
    rescue ActionController::ParameterMissing, ActiveRecord::RecordInvalid
      render json: ERRORS[:entity_associations_bad_format], status: :bad_request
    end

    def json
      Api.as_api_json(@list.list_entities.to_a)
        .merge!('included' => Array.wrap(@list.last_reference.api_data))
    end
  end
end
