class Tag < ActiveRecord::Base
  has_many :taggings

  validates :name, uniqueness: true, presence: true
  validates :description, presence: true

  def restricted?
    restricted
  end

  # Tag (implicit) -> Hash[String -> Array[Tagable]]
  def tagables_grouped_by_resource_type
    taggings.map(&:tagable).reduce({}) do |acc, tagable|
      acc.merge(tagable.class.name => (acc[tagable.class.name] || []) + [tagable])
    end
  end

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
end
