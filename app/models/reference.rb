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

  def self.all_entity_references(entity)
    link_to_ref_hash = Proc.new { |l| { object_model: 'Relationship', object_id: l.relationship_id } }
    rel_ids = entity.links.map(&:relationship_ids)
    objects = entity.links.collect(&link_to_ref_hash).append({ object_model: 'Entity', object_id: entity.id })
    recent_references(objects)
  end

  # input: hash with keys: :class_name, :object_id
  # output: str
  private_class_method def self.generate_where(h)
    "( object_model = '#{h[:class_name]}' AND object_id IN (#{h[:object_ids].join(',')}) )"
  end
end
