module Routes
  # converts 'entities' to 'org' or 'person'
  MODIFY_PATH = proc do |entity, *args|
    raise ArgumentError, "#{__method__}'s first argument must be an <entity>" unless entity.is_a? Entity
    return super(entity, *args).gsub('/entities/', '/org/') if entity.org?
    return super(entity, *args).gsub('/entities/', '/person/') if entity.person?
  end
  private_constant :MODIFY_PATH

  ROUTES_TO_MODIFY = Rails.application.routes.routes.named_routes.to_a.map do |route_name, route|
    if route_name.include?('entity') and not route_name.include?('api')
      route_name if route.constraints[:request_method].match('GET')
    end
  end.compact.freeze

  # If a Controller or Helper includes this module, it will convert
  # these Rails router helper methods to use nicer paths
  ROUTES_TO_MODIFY.each do |route|
    define_method("#{route}_path", MODIFY_PATH)
    define_method("#{route}_url", MODIFY_PATH)
  end
end
