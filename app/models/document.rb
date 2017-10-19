class Document < ActiveRecord::Base
  has_many :references

  validates :url, presence: true, url: true
  validates :url_hash, presence: true, uniqueness: true
  validates :name, length: { maximum: 255 }

  before_validation :trim_whitespace, :set_hash

  REF_TYPES = {
    1 => 'Generic',
    2 => 'FEC Filing',
    3 => 'Newspaper',
    4 => 'Government Document'
  }.freeze

  REF_TYPE_LOOKUP = {
    :generic => 1,
    :fec => 2,
    :newspaper => 3,
    :government => 4
  }.freeze

  def ref_types_display
    REF_TYPES[ref_type]
  end

  #---------------#
  # CLASS METHODS #
  #---------------#

  # Returns the reference types as an array: [ [name, number], ... ]
  # Removes the FEC filings option
  # Used by the add reference modal in _reference_new.html.erb
  def self.ref_type_options
    REF_TYPES.except(2).map(&:reverse)
  end

  # Retrieve a Document by url
  # input: String
  # output: <Document> | nil
  def self.find_by_url(url)
    raise Exceptions::InvalidUrlError if url.blank? || !valid_url?(url)
    find_by_url_hash url_to_hash(url)
  end

  def self.valid_url?(url)
    URI.parse(url.strip).is_a?(URI::HTTP)
  rescue URI::InvalidURIError
    false
  end

  # The number of documents for the entity (and it's relationships)_
  # Effectively, this is the total count for the
  # query `documents_for_entity`
  # <Entity> | Integer -> Integer
  def self.documents_count_for_entity(entity)
    entity_id = Entity.entity_id_for(entity)
    sql = <<~SQL
            SELECT count(distinct entity_document_ids.document_id)
            FROM (
                  (
                    SELECT `references`.document_id
                    FROM link
                    INNER JOIN `references` ON `references`.referenceable_id = link.relationship_id AND `references`.referenceable_type = 'Relationship'
                    WHERE entity1_id = #{entity_id}
                  )
                  UNION ALL
                  (
                    SELECT document_id
                    FROM `references`
                    WHERE referenceable_id = #{entity_id} AND referenceable_type = 'Entity'
                  )
            ) AS entity_document_ids
    SQL
    connection.execute(sql).first.first
  end

  #
  # TODO: this query is slow and can probably be better optimized
  #
  # To gather the source links documenting an entity
  # we need to include the documents for the entity's relationships as well
  # input: entity: <Entity> or Integer,
  #        page: Integer,
  #        per_page: Integer,
  #        exclude_type: Integer | Symbol
  # Output: [Document]
  def self.documents_for_entity(entity:, page:, per_page: Entity::PER_PAGE, exclude_type: nil)
    entity_id = Entity.entity_id_for(entity)
    offset = ((page.to_i - 1) * per_page)
    exclude_ref_type_sql = exclude_type.present? ? "WHERE documents.ref_type <> #{fetch_ref_type(exclude_type)}" : ''
    # yes, i'm aware this is kind of insane - ziggy
    sql = <<~SQL
            SELECT documents.*
            FROM (
                 SELECT all_entity_refs.document_id as document_id,
                        max(all_entity_refs.updated_at) as updated_at
                 FROM (
                        (
                          SELECT `references`.document_id as document_id,
    	                          `references`.updated_at as updated_at
                          FROM link
                          INNER JOIN `references` ON `references`.referenceable_id = link.relationship_id AND `references`.referenceable_type = 'Relationship'
                          WHERE entity1_id = #{entity_id}
                        )
	                UNION ALL
                        (
                          SELECT document_id,
                                 updated_at
                          FROM `references`
                          WHERE referenceable_id = #{entity_id} AND referenceable_type = 'Entity'
                        )
                       ) AS all_entity_refs
                GROUP BY all_entity_refs.document_id
            ) as documents_for_entity
            INNER JOIN documents ON documents.id = documents_for_entity.document_id
            #{exclude_ref_type_sql}
            ORDER BY documents_for_entity.updated_at desc
            LIMIT #{per_page}
            OFFSET #{offset}
          SQL

    find_by_sql(sql)
  end

  #-----------------------#
  # PRIVATE CLASS METHODS #
  #-----------------------#

  def self.url_to_hash(url)
    Digest::SHA1.hexdigest(url)
  end

  def self.fetch_ref_type(type)
    if REF_TYPES.keys.include?(type)
      type
    elsif REF_TYPE_LOOKUP.keys.include?(type)
      REF_TYPE_LOOKUP.fetch(type)
    else
      raise ArgumentError, "#{type} is an invalid ref_type"
    end
  end

  private_class_method :url_to_hash, :fetch_ref_type

  #--------------------------#
  # PRIVATE INSTANCE METHODS #
  #--------------------------#

  private

  def trim_whitespace
    self.url.strip! unless url.nil?
    self.name.strip! unless name.nil?
  end

  def set_hash
    self.url_hash = url_to_hash unless url.blank?
  end

  def url_to_hash
    Document.send(:url_to_hash, url)
  end
end
