class Tag < ApplicationRecord
  include Pagination
  PER_PAGE = 20

  has_many :taggings

  # create associations for all tagable classes
  # ie: tag#entities, tag#lists, tag#relationships, etc...
  Tagable.classes.each do |klass|
    has_many klass.category_sym, through: :taggings, source: :tagable, source_type: klass.name
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

  # ANY -> Kaminari::PaginatableArray
  def tagables_for_homepage(tagable_category, **kwargs)
    public_send "#{tagable_category}_for_homepage", **kwargs
  end

  # keyword args (person_page, org_page) -> Hash
  def entities_for_homepage(person_page: 1, org_page: 1)
    %w[Person Org].reduce({}) do |acc, type|
      page = binding.local_variable_get("#{type.downcase}_page").to_i
      acc.merge(type => paginate(page, PER_PAGE, *count_and_sort_entities(type, page)))
    end
  end

  def lists_for_homepage(page: 1)
    paginate(page,
             PER_PAGE,
             *count_and_sort_lists(page))
  end

  def relationships_for_homepage(page: 1)
    relationships
      .order(updated_at: :desc)
      .page(page)
      .per(PER_PAGE)
  end

  def recent_edits_for_homepage(page: 1)
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
      entities_by_relationship_count(entity_type.to_s, page),
      entities.where(primary_ext: entity_type.to_s).count
    ]
  end

  # str|class, int -> [EntityActiveRecord]
  def entities_by_relationship_count(entity_type, page = 1)
    # guard against SQL injection
    raise ArgumentError unless %w[Person Org].include?(entity_type.to_s)
    page = page.to_i

    sql = <<-SQL
         SELECT taggings.tagable_id,
                SUM( case when linked_taggings.id is null then 0
		     when taggings.id is null then 0
		     else 1 end ) as relationship_count

         FROM taggings
         INNER JOIN entity ON entity.id = taggings.tagable_id AND entity.is_deleted = 0 AND entity.primary_ext = '#{entity_type}'
         LEFT JOIN link ON link.entity1_id = taggings.tagable_id
         LEFT JOIN taggings as linked_taggings ON linked_taggings.tagable_id = link.entity2_id AND linked_taggings.tagable_class = 'Entity' AND linked_taggings.tag_id = #{id}
         WHERE taggings.tag_id = #{id} AND taggings.tagable_class = 'Entity'
         GROUP BY taggings.tagable_id
         ORDER BY relationship_count desc
         LIMIT #{PER_PAGE}
         OFFSET #{(page - 1) * PER_PAGE}
    SQL

    entities_and_counts = ApplicationRecord.connection.execute(sql).to_a

    relationship_counts = entities_and_counts.reduce({}) do |memo, arr|
      memo.merge(arr.first => arr.second)
    end

    Entity.find(entities_and_counts.map(&:first)).to_a.map! do |entity|
      entity.singleton_class.class_eval { attr_reader :relationship_count }
      entity.instance_variable_set(:@relationship_count, relationship_counts.fetch(entity.id))
      entity
    end
  end

  def count_and_sort_lists(page = 1)
    [lists_by_entity_count(page), lists.count]
  end

  def lists_by_entity_count(page = 1)
    page = page.nil? ? 1 : page.to_i
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
