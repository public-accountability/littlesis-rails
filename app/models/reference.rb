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

  # Returns recent references for the given object
  # input: {object_model: str, object_id: int}, or array of objs , or array of ActiveModels
  # Output: Array
  def self.recent_references(objects, limit=20)
    objects = Array.new << objects if objects.class == Hash
    Reference.where(generate_recent_references_wheres(objects)).order('updated_at DESC').limit(limit)
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

  # Array -> Str
  # Generates where statement to query for  recent references.
  # Input can be an array of hashes or ActiveRecord models
  def self.generate_recent_references_wheres(objects)
    case objects[0]
    when Hash
      objects.map { |o| "(object_model = '#{o[:object_model]}' AND object_id = #{o[:object_id]})" }.join(' OR ')
    when Entity, Relationship
      objects.map { |o| "(object_model = '#{o.class.to_s}' AND object_id = #{o.id})" }.join(' OR ')
    else
      raise ArgumentError, :message => "Input must be an Array of Hashes or Active Record models"
    end
  end
end
