module Routes
  # converts 'entities' to 'org' or 'person'
  MODIFY_PATH = proc do |entity|
    return super(entity).gsub('/entities/', '/org/') if entity.org?
    return super(entity).gsub('/entities/', '/person/') if entity.person?
  end
  private_constant :MODIFY_PATH

  # If a Controller or Helper includes this module, it will convert
  # these Rails router helper methods to use nicer paths
  [:entity, :edit_entity, :match_donations_entity].each do |route|
    define_method("#{route}_path", MODIFY_PATH)
    define_method("#{route}_url", MODIFY_PATH)
  end
end
