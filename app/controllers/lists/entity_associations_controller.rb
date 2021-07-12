# frozen_string_literal: true

module Lists
  class EntityAssociationsController < ApplicationController
    before_action :authenticate_user!, only: :new
    before_action :block_restricted_user_access, only: :new
    before_action :set_list
    before_action :set_permissions
    before_action -> { check_access(:editable) }

    def new
    end

    def create
      payload = create_entity_associations_payload
      return render json: ERRORS[:entity_associations_bad_format], status: :bad_request unless payload

      dattrs = Document::DocumentAttributes.new(payload['reference_attrs'])

      unless dattrs.valid?
        return render json: ERRORS[:entity_associations_invalid_reference], status: :bad_request
      end

      @list
        .add_entities(payload['entity_ids'])
        .add_reference(dattrs)
        .save!

      json = Api.as_api_json(@list.list_entities.to_a).merge!('included' => Array.wrap(@list.last_reference.api_data))

      render json: json, status: :ok
    end

    private

    def set_list
      @list = List.find(params[:id])
    end

    def create_entity_associations_payload
      payload = params.require('data').map { |x| x.permit('type', 'id', { 'attributes' => ['url', 'name'] }) }
      {
        'entity_ids'      => payload.select { |x| x['type'] == 'entities' }.map { |x| x['id'] },
        'reference_attrs' => payload.select { |x| x['type'] == 'references' }.map { |x| x['attributes'] }.first
      }
    rescue ActionController::ParameterMissing, ActiveRecord::RecordInvalid
      nil
    end
  end
end
