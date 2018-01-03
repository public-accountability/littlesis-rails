class Tag < ApplicationRecord
  include Pagination
  PER_PAGE = 20

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

  # Integer -> Kaminari::PaginatableArray
  def tagables_for_homepage(tagable_category, *args)
    send("#{tagable_category}_for_homepage", *args)
  end

  # keyword args (person_page, org_page) -> Hash
  def entities_for_homepage(person_page: 1, org_page: 1)
    %w[Person Org].reduce({}) do |acc, type|
      page = binding.local_variable_get("#{type.downcase}_page").to_i
      acc.merge(type => paginate(page, PER_PAGE, *count_and_sort_entities(type, page)))
    end
  end

  def lists_for_homepage(page = 1)
    paginate(page,
             PER_PAGE,
             *count_and_sort_lists(page))
  end

  def relationships_for_homepage(page = 1)
    relationships
      .order(updated_at: :desc)
      .page(page)
      .per(PER_PAGE)
  end

  def recent_edits_for_homepage(page = 1)
    paginate(page,
             PER_PAGE,
             recent_edits(page),
             taggings.count * 2)
  end

  # type EditsIdHash = {
  #   tagable:            Tagable,
  #   tagable_class:      String,
  #   event_timestamp:    Timestamp,
  #   editor:             User, (Rails user)
  #   event:              Enum('tag_added', 'tagable_updated')
  # }
  # Integer -> [EditsHash]

  def recent_edits(page = 1)
    edit_id_hashes = recent_edit_ids(page)
    tagables_by_class_and_id = tagables_by_class_and_id_for(edit_id_hashes)
    editors_by_id = editors_by_id(edit_id_hashes)

    edit_id_hashes.map do |h|
      {
        'tagable_class'   => h['tagable_class'],
        'event'           => h['event'],
        'event_timestamp' => h['event_timestamp'],
        'tagable'         => tagables_by_class_and_id.dig(h['tagable_class'], h['tagable_id']),
        'editor'          => editors_by_id[h['editor_id']]
      }
    end
  end

  private

  def count_and_sort_entities(entity_type, page = 1)
    [
      entities_by_relationship_count(entity_type, page),
      entities.where(primary_ext: entity_type.to_s).count
    ]
  end

  # Self -> [EntityActiveRecord, Int]
  def entities_by_relationship_count(entity_type, page = 1)
    # guard against SQL injection
    raise ArgumentError unless %w[Person Org].include?(entity_type)
    page = page.to_i

    entity_counts_sql = <<-SQL
      SELECT tagged_entity_links.tagable_id,

              # only count record in doubly-joined table if both entities in a link have correct tag
              SUM( case when tagged_entity_links.entity1_id is null then 0
       	         	when taggings.id is null then 0
	                else 1 end ) as relationship_count

       # join all of a tag's entities all of each entity's links
       FROM (
	    SELECT taggings.tagable_id, link.*
	    FROM taggings
	    LEFT JOIN link ON link.entity1_id = taggings.tagable_id
	    WHERE taggings.tag_id = #{id} AND taggings.tagable_class = 'Entity'
       ) AS tagged_entity_links

       # join to find out if linked-to entities are also tagged with our tag
       LEFT JOIN taggings
            ON tagged_entity_links.entity2_id = taggings.tagable_id
     	       AND taggings.tag_id = #{id}
	       AND taggings.tagable_class = 'Entity'

       # cull record set to unique list of tagged entities with relationship counts
       GROUP BY tagged_entity_links.tagable_id

       # sort
       ORDER BY relationship_count desc
    SQL

    sql = <<-SQL
       SELECT *
       FROM (#{entity_counts_sql}) AS entity_counts
       # recover entity fields
       INNER JOIN entity ON entity_counts.tagable_id = entity.id
       # filter by entity subtype
       WHERE entity.primary_ext = '#{entity_type}'
       # paginate
       LIMIT #{PER_PAGE}
       OFFSET #{(page - 1) * PER_PAGE}
      SQL

    Entity.find_by_sql(sql)
  end

  def count_and_sort_lists(page = 1)
    [lists_by_entity_count(page), lists.count]
  end

  def lists_by_entity_count(page = 1)
    page = page.to_i
    query = <<-SQL
      SELECT DISTINCT ls_list.*, COUNT(ls_list_entity.id) AS entity_count
      FROM ls_list
      INNER JOIN taggings ON ls_list.id = taggings.tagable_id
        AND taggings.tag_id = #{id}
        AND taggings.tagable_class = 'List'
      LEFT JOIN ls_list_entity ON ls_list_entity.list_id = ls_list.id
      WHERE ls_list.is_deleted = 0
      GROUP BY ls_list.id
      ORDER BY entity_count DESC
      LIMIT #{PER_PAGE}
      OFFSET #{(page - 1) * PER_PAGE};
    SQL
    List.find_by_sql query
  end

  # type EditsIdHash = {
  #   tagging_id:          Integer,
  #   tagable_id:          Integer,
  #   tagable_class:       String,
  #   tagging_created_at:  Timestamp,
  #   event_timestamp:     Timestamp,
  #   editor:              Integer,
  #   event:               Enum('tag_added', 'tagable_updated')
  # }
  # Integer -> [EditsIdHash]
  def recent_edit_ids(page = 1)
    sql = <<-SQL
      (
        SELECT taggings.id as tagging_id,
               taggings.tagable_id,
               taggings.tagable_class,
               taggings.created_at as tagging_created_at,
               COALESCE(entity.updated_at, ls_list.updated_at, relationship.updated_at) AS event_timestamp,
               COALESCE(entity.last_user_id, ls_list.last_user_id, relationship.last_user_id) AS editor_id,
               'tagable_updated' as event
	FROM taggings
	LEFT JOIN entity ON taggings.tagable_id = entity.id AND taggings.tagable_class = 'Entity'
 	LEFT JOIN ls_list ON taggings.tagable_id = ls_list.id AND taggings.tagable_class = 'List'
	LEFT JOIN relationship ON taggings.tagable_id = relationship.id AND taggings.tagable_class = 'Relationship'
	WHERE taggings.tag_id = #{id}
            # adding a tag triggers a callback that also updates the tagable. This clause excludes those updates
	    AND abs(TIMESTAMPDIFF(SECOND, taggings.created_at, COALESCE(entity.updated_at, ls_list.updated_at, relationship.updated_at))) > 100
      )
        UNION
      (
        SELECT taggings.id as tagging_id,
	       taggings.tagable_id,
	       taggings.tagable_class,
	       taggings.created_at AS tagging_created_at,
	       taggings.created_at AS event_timestamp,
               taggings.last_user_id AS editor_id,
	       'tag_added' AS event
        FROM taggings
	WHERE taggings.tag_id = #{id}
      )
        ORDER BY event_timestamp DESC
        LIMIT #{PER_PAGE}
        OFFSET #{(page.to_i - 1) * PER_PAGE}
    SQL

    # NOTE: our version of Mysql2::Result is missing the very convenient method: #to_hash ...why?
    # we should be able to do ApplicationRecord.connection.execute(sql).to_hash instead of
    # populating the array ourselves...
    result = []
    ApplicationRecord.connection.execute(sql).each(:as => :hash) { |h| result << h }
    result
  end

  # type TagablesByClassAndId = {
  #   "Relationship" => { [id: Integer] => Relationship }
  #   "Entity"       => { [id: Integer] => Entity }
  #   "List"         => { [id: Integer] => List }
  # }
  # [EditsIdHash] -> TagablesByClassAndId
  def tagables_by_class_and_id_for(edits_id_hash)
    base = { "Relationship" => {}, "Entity" => {}, "List" => {} }
    edits_id_hash
      .group_by { |h| h['tagable_class'] }
      .transform_values { |tagable_array| tagable_array.map { |h| h['tagable_id'] }.uniq }
      .to_a
      .reduce(base) do |acc, (klass, tagable_ids)|
        klass.constantize.find(tagable_ids).each { |tagable| acc[klass].store(tagable.id, tagable) }
        acc
      end
  end

  # type EditorsById = { [id: Integer] => User }
  # [EditsIdHash] => EditorsById
  def editors_by_id(id_hashes)
    ids = id_hashes.map { |h| h['editor_id'] }
    SfGuardUser.find(ids)
      .to_a
      .map(&:user)
      .zip(ids)
      .reduce({}) { |acc, (editor, id)| acc.merge!(id => editor) }
  end
end
