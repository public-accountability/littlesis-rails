module EntityMatcher
  SEARCH_OPTS = {
    :per_page => 200,
    :ranker => :none,
    :populate => true,
    :with => { is_deleted: false }
  }.freeze

  # str --> ThinkginSphinx
  # Search database for potential matches
  def self.search(query, primary_ext:)
    Entity.search("@(name,aliases,name_nick) ( #{query} )",
                  SEARCH_OPTS.deep_merge(:with => { primary_ext: primary_ext }))
  end

  # == These use the classes in EntityMatcher::Query
  #    to first cast the input into a formated sphinx query

  def self.search_by_entity(entity)
    public_send("search_by_#{entity.primary_ext.downcase}", entity)
  end

  def self.search_by_person(person)
    search EntityMatcher::Query::Person.new(person).to_s, primary_ext: 'Person'
  end

  def self.search_by_org(org)
    search EntityMatcher::Query::Org.new(org).to_s, primary_ext: 'Org'
  end

  def self.search_by_name(*names)
    search EntityMatcher::Query::Names.new(*names).to_s, primary_ext: 'Person'
  end
end
