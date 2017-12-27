module Routes
  # converts 'entities' to 'org' or 'person'
  MODIFY_PATH = proc do |entity, *args|
    raise ArgumentError, "#{__method__}'s first argument must be an <entity>" unless entity.is_a? Entity
    return super(entity, *args).gsub('/entities/', '/org/') if entity.org?
    return super(entity, *args).gsub('/entities/', '/person/') if entity.person?
  end
  private_constant :MODIFY_PATH

  ROUTES_TO_MODIFY = Rails.application.routes.routes.map do |route|
    if route.name.present? && route.name.include?('entity') && !route.name.include?('api')
      route.name if route.verb == 'GET'
    end
  end.compact.freeze

  # If a Controller or Helper includes this module, it will convert
  # these Rails router helper methods to use nicer paths
  ROUTES_TO_MODIFY.each do |route|
    define_method("#{route}_path", MODIFY_PATH)
    define_method("#{route}_url", MODIFY_PATH)
  end
end
