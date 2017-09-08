class Tag < ActiveRecord::Base
  has_many :taggings

  validates :name, uniqueness: true, presence: true
  validates :description, presence: true

  DEFAULT_TAGGING_PAGES = Tagable::TAGABLE_CLASSES.reduce({}) do |acc, klass|
    acc.merge(Tagable.page_param_of(klass).to_sym => 1)
  end

  def restricted?
    restricted
  end

  # Tag (implicit) -> Hash[String -> ActiveRecord[Tagging]]
  def taggings_grouped_by_class(params = DEFAULT_TAGGING_PAGES)
    #taggings.includes(:tagable).map(&:tagable).group_by { |t| t.class.name }
    Tagable::TAGABLE_CLASSES.reduce({}) do |acc, tagable_class|
      acc.merge(
        tagable_class.to_s => taggings.includes(:tagable)
                             .where(tagable_class: tagable_class)
                             .page(params[Tagable.page_param_of(tagable_class)])
      )
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
