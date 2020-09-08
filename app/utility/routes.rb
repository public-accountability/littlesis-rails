# frozen_string_literal: true

module Routes
  # converts 'entities' to 'org' or 'person'
  REPLACE_ENTITIES_IN_STRING = proc do |str, entity|
    if entity.org?
      str.gsub('/entities/', '/org/')
    elsif entity.person?
      str.gsub('/entities/', '/person/')
    end
  end

  MODIFY_PATH = proc do |entity, *args|
    raise ArgumentError, "#{__method__}'s first argument must be an <entity>" unless entity.is_a? Entity
    REPLACE_ENTITIES_IN_STRING.call(super(entity, *args), entity)
  end
  private_constant :MODIFY_PATH

  EXCLUDED_PATHS = %w[
    new_entity
    admin_entity_matcher
    external_entity
    new_deletion_requests_entity
    deletion_requests_entities
    review_deletion_requests_entity
  ].freeze

  ROUTES_TO_MODIFY = Rails.application.routes.routes.map do |route|
    if route.name.present? && route.name.include?('entity') && !route.name.include?('api') && !EXCLUDED_PATHS.include?(route.name)
      route.name if route.verb == 'GET'
    end
  end.compact.freeze

  # If a Controller or Helper includes this module, it will convert
  # these Rails router helper methods to use nicer paths
  ROUTES_TO_MODIFY.each do |route|
    define_method("#{route}_path", MODIFY_PATH)
    define_method("#{route}_url", MODIFY_PATH)

    define_singleton_method("#{route}_path") do |entity|
      modify_entity_path(
        Rails.application.routes.url_helpers.public_send("#{route}_path", entity),
        entity
      )
    end

    define_singleton_method("#{route}_url") do |entity|
      modify_entity_path(
        Rails.application.routes.url_helpers.public_send("#{route}_url", entity),
        entity
      )
    end
  end

  def self.modify_entity_path(str, entity)
    raise ArgumentError unless str.is_a?(String) && entity.is_a?(Entity)

    REPLACE_ENTITIES_IN_STRING.call(str, entity)
  end
end
