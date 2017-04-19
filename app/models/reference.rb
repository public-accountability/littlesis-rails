class Reference < ActiveRecord::Base
  include SingularTable
  has_paper_trail :on => [:update, :destroy]

  has_one :os_match
  has_one :reference_excerpt
  has_one :os_donation, :through => :os_match

  validates :source, length: { maximum: 1000 }, presence: true
  validates :source_detail, length: { maximum: 255 }
  validates_presence_of :object_id, :object_model

  @@ref_types = { 1 => 'Generic', 2 => 'FEC Filing', 3 => 'Newspaper', 4 => 'Government Document' }

  def ref_types
    @@ref_types
  end

  def ref_type_display
    @@ref_types[ref_type]
  end

  # Returns the reference types as an array: [ [name, number], ... ]
  # Removes the FEC filings option
  # Used by the add reference modal in _reference_new.html.erb
  def self.ref_type_options
    @@ref_types.to_a.map { |x| x.reverse }.delete_if { |x| x[1] == 2 }
  end

  def excerpt
    reference_excerpt.nil? ? nil : reference_excerpt.body
  end

  # The regular validation process includes checks for object_id, and object_model.
  # This checks that the other fields are valid, so we know we can safely create the object if we provided the object_id and object_model
  # Returns: Hash
  # The hash will be empty if there are no errors
  def validate_before_create
    errors = Hash.new
    errors[:source] = 'Missing reference Url' if self.source.blank?
    errors[:name] = 'Missing reference name' if self.name.blank?
    errors
  end

  # Returns recent references for a set of models and ids
  # input: hash | array, int
  # hash format: { class_name: 'ClassName', object_ids: [object_ids] }
  # You can also input an array of hashes.
  # example:
  #    .recent_references( [ { :class_name = "Entity", :object_ids => [10,11,12] }, { :class_name = "Relationship", :object_ids => [100,101] } ] )
  def self.recent_references(info, limit = 20)
    raise ArgumentError unless info.is_a?(Hash) || info.is_a?(Array)
    info_array = info.is_a?(Hash) ? [info] : info
    where_statement = info_array.collect { |h| generate_where(h) }.join(' OR ')
    where(where_statement).order('updated_at DESC').limit(limit)
  end
  
  # input: <Entity> or Integer
  # output: [ <Reference> ]
  # Retrives references for the entity AND for relationships that the entity is in
  # Note: The returned  models do not contain all the fields that are in the Reference table
  def self.all_entity_references(entity)
    entity_id = entity.is_a?(Entity) ? entity.id : entity
    Reference.find_by_sql([
      "SELECT ref.source, ref.name, ref.id, ref.object_model, ref.object_id, ref.updated_at, ref.ref_type
      FROM link 
      INNER JOIN reference as ref ON (ref.object_id = link.relationship_id AND ref.object_model = 'Relationship')
      WHERE link.entity1_id = ?
      UNION ALL
      SELECT reference.source, reference.name, reference.id, reference.object_model, reference.object_id, reference.updated_at, reference.ref_type
      FROM reference
      WHERE object_model = 'Entity' AND object_id = ?", entity_id, entity_id])
  end

  # This query is similar to "recent_references"
  # TODO: replace recent_references with with query
  #
  # This returns only three reference fields: source (url), name, updated_at
  # It returns only unique combinations of source and name
  # NOTE: It skips source links for FEC filing (ref_type = 2)
  # input: <Entity> or Int, Int, Int
  # output: [ {} ]
  def self.recent_source_links(entity, page = 1, per_page = 10)
    entity_id = get_entity_id(entity)
    limit = per_page
    offset = (page - 1) * limit
    Reference.find_by_sql(
      ["SELECT *
        FROM (
        (
	 SELECT ref.source as source, ref.name as name, max(ref.updated_at) as updated_at
       	 FROM link 
	 INNER JOIN reference as ref ON (ref.object_model = 'Relationship' AND ref.object_id = link.relationship_id AND ref_type <> 2)
	 WHERE link.entity1_id = ?
	 GROUP BY ref.source, ref.name
	 )
	 UNION ALL
         (
          SELECT reference.source as source, reference.name as name, max(reference.updated_at) as updated_at
	  FROM reference
  	  WHERE object_model = 'Entity' AND object_id = ?
  	  GROUP BY reference.source, reference.name
         )
        ) as r
        ORDER BY r.updated_at desc
        LIMIT ? OFFSET ?"] + [entity_id, entity_id, limit, offset])
          .map { |ref| ref.attributes.except('id') }
  end

  # returns the number of unique urls documenting the entity and it's relationships
  def self.unique_url_count(entity)
    entity_id = get_entity_id(entity)
    raise ArugmentError, "entity_id must be an interger" unless entity_id.is_a? Integer
    sql = "SELECT sum(c)
     FROM (
     (
      SELECT count(distinct ref.source) as c
      FROM link
      RIGHT JOIN reference as ref ON (ref.object_model = 'Relationship' AND ref.object_id = link.relationship_id)
      WHERE link.entity1_id = #{entity_id}
     )
      UNION ALL
     (
      SELECT count(distinct reference.source) as c
      FROM reference
      WHERE object_model = 'Entity' AND object_id = #{entity_id}
     )
     ) as r"
    ActiveRecord::Base.connection.execute(sql).to_a[0][0]
  end

  private_class_method def self.get_entity_id(entity)
    return entity.id if entity.is_a? Entity
    return entity if entity.is_a? Integer
    raise ArgumentError, "This function must be called with an <Entity> or an <Integer>"
  end

  # input: hash with keys: :class_name, :object_id
  # output: str
  private_class_method def self.generate_where(h)
    "( object_model = '#{h[:class_name]}' AND object_id IN (#{h[:object_ids].join(',')}) )"
  end
end
