class Tag < ActiveRecord::Base
  TAGABLE_PAGINATION_LIMIT = 20

  has_many :taggings

  # create associations for all tagable classes
  # ie: tag#entities, tag#lists, tag#relationships, etc...
  Tagable.classes.each do |klass|
    has_many klass.category_sym, through: :taggings, source: :tagable, source_type: klass
  end

  validates :name, uniqueness: true, presence: true
  validates :description, presence: true

  # CLASS METHODS

  # (set, set) -> hash
  def self.parse_update_actions(client_ids, server_ids)
    {
      ignore: client_ids & server_ids,
      add: client_ids - server_ids,
      remove: server_ids - client_ids
    }
  end

  # String -> [Tag]
  def self.search_by_names(phrase)
    Tag.lookup.keys
      .select { |tag_name| phrase.downcase.include?(tag_name) }
      .map { |tag_name| lookup[tag_name] }
  end

  # String -> Tag | Nil
  # Search through tags find tag by name
  def self.search_by_name(query)
    lookup[query.downcase]
  end

  def self.lookup
    @lookup ||= Tag.all.reduce({}) do |acc, tag|
      acc.tap { |h| h.store(tag.name.downcase.tr('-', ' '), tag) }
    end
  end

  # INSTANCE METHODS

  def restricted?
    restricted
  end

  def tagables_for_homepage(params = {})
    # we join on *both* entity1_id and entity2_id and filter out rows w/o both ids so that
    # our result set will only include taggings in which both elements in a relationship are tagged
    sql = <<-SQL
      SELECT entity1_id, count(*) as related_tagged_entities
      FROM link
      LEFT JOIN taggings as e1t on e1t.tagable_id = link.entity1_id AND e1t.tagable_class = 'Entity' AND e1t.tag_id = #{id}
      LEFT JOIN taggings as e2t on e2t.tagable_id = link.entity2_id AND e2t.tagable_class = 'Entity' AND e2t.tag_id = #{id}
      WHERE e1t.id is not null AND e2t.id is not null
      GROUP BY entity1_id
      ORDER BY related_tagged_entities desc
    SQL

    ActiveRecord::Base.connection.execute(sql).to_a
  end
end
