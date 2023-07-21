# frozen_string_literal: true

module EntityExtensions
  extend ActiveSupport::Concern

  ALL_EXTENSION_NAMES = [
    'None',
    'Person',
    'Org',
    'PoliticalCandidate',
    'ElectedRepresentative',
    'Business',
    'GovernmentBody',
    'School',
    'MembershipOrg',
    'Philanthropy',
    'NonProfit',
    'PoliticalFundraising',
    'PrivateCompany',
    'PublicCompany',
    'IndustryTrade',
    'LawFirm',
    'LobbyingFirm',
    'PublicRelationsFirm',
    'IndividualCampaignCommittee',
    'Pac',
    'OtherCampaignCommittee',
    'MediaOrg',
    'ThinkTank',
    'Cultural',
    'SocialClub',
    'ProfessionalAssociation',
    'PoliticalParty',
    'LaborUnion',
    'Gse',
    'BusinessPerson',
    'Lobbyist',
    'Academic',
    'MediaPersonality',
    'ConsultingFirm',
    'PublicIntellectual',
    'PublicOfficial',
    'Lawyer',
    'Couple', # deprecated
    'ResearchInstitute',
    'GovernmentAdvisoryBody',
    'EliteConsensus'
  ].freeze

  ALL_EXTENSION_NAMES_WITH_FIELDS = [
    'Person',
    'Org',
    'PoliticalCandidate',
    'ElectedRepresentative',
    'Business',
    'School',
    'PublicCompany',
    'GovernmentBody',
    'BusinessPerson',
    'Lobbyist',
    'PoliticalFundraising'
  ].freeze

  included do
    # extensions
    has_one :person, inverse_of: :entity, dependent: :destroy
    has_one :org, inverse_of: :entity, dependent: :destroy
    has_one :public_company, inverse_of: :entity, dependent: :destroy
    has_one :school, inverse_of: :entity, dependent: :destroy
    has_one :business_person, inverse_of: :entity, dependent: :destroy
    has_one :lobbyist, inverse_of: :entity, dependent: :destroy
    has_one :political_candidate, inverse_of: :entity, dependent: :destroy
    has_one :elected_representative, inverse_of: :entity, dependent: :destroy
    has_one :business, inverse_of: :entity, dependent: :destroy
    has_one :government_body, inverse_of: :entity, dependent: :destroy
    has_one :political_fundraising, inverse_of: :entity, dependent: :destroy

    ## extension nexted attributes
    accepts_nested_attributes_for :person, :public_company, :school, :business
  end

  class_methods do
    def with_exts(exts)
      ext_ids = exts.map { |ext| all_extension_names.index(ext) }.compact
      joins(:extension_records).where(extension_record: { definition_id: ext_ids })
    end

    # Names of the extensions (ExtensionDefinition) in order of their definition_id
    # Can be used as a look up table. For instance
    # Entity.all_extension_names[27] => LaborUnion
    def all_extension_names
      ALL_EXTENSION_NAMES
    end

    def all_extension_names_with_fields
      ALL_EXTENSION_NAMES_WITH_FIELDS
    end

    def extension_with_field?(name_or_id)
      ALL_EXTENSION_NAMES_WITH_FIELDS.include? ext_name_or_id_to_name(name_or_id)
    end
  end

  ##
  # extensions
  #

  def create_primary_ext
    fields = person? ? NameParser.parse_to_hash(name) : {}
    add_extension(primary_ext, fields)
  end

  def person?
    primary_ext == 'Person'
  end

  def org?
    primary_ext == 'Org'
  end

  def school?
    org? && has_extension?('School')
  end

  def other_ext
    person? ? 'Org' : 'Person'
  end

  # Returns a hash of all attributes for all extensions (that have attrs) for the entity.
  # All entities will have attributes associated with 'Person' or 'Org'
  def extension_attributes
    extensions_with_attributes.values.reduce(:merge)
  end

  # Returns an array of all extension models
  def extension_models
    (extension_names & Entity.all_extension_names_with_fields).map do |name|
      name.constantize.find_by_entity_id(id)
    end
  end

  def types
    extension_definitions.map(&:display_name)
  end

  # Returns a hash where the key in each key/value pair is the extension name
  # and the value is a hash of the attributes for that extension
  def extensions_with_attributes
    extension_models.reduce({}) do |memo, model|
      memo.merge(model.class.name => model.attributes.except('id', 'entity_id') )
    end
  end

  def extension_ids
    extension_records.map(&:definition_id)
  end

  def extension_ids_without_primary
    extension_ids.delete_if { |id| id == 1 || id == 2 }
  end

  # used in the edit entities view as value for extension_definition_ids
  def extension_ids_without_primary_stringified
    extension_ids_without_primary.join(',')
  end

  # Returns array containing the name of all entity extensions (ExtensionRecord)
  # All entities will have at least one: 'Person' or 'Org
  def extension_names
    extension_ids.collect { |id| self.class.all_extension_names[id] }
  end

  def has_extension?(name_or_id)
    name_or_id_to_name(name_or_id)
    def_id = self.class.all_extension_names.index(name_or_id) if name_or_id.is_a? String
    def_id = name_or_id if name_or_id.is_a? Integer
    extension_ids.include?(def_id)
  end

  # Adds a new extension. Creates ExtensionRecord and extension model if required
  # Call with the name of the extension model or with the definition id
  # It will not create duplicates and is safe to run multiple times with with the same value
  # Example: Entity.find(123).add_extension('Business')
  def add_extension(name_or_id, fields = {})
    name = name_or_id_to_name(name_or_id)
    fields[:entity] = self
    name.constantize.create(fields) if extension_with_fields?(name) && name.constantize.where(entity_id: id).count.zero?
    def_id = ExtensionDefinition.find_by_name(name).id
    ExtensionRecord.find_or_create_by!(entity_id: id, definition_id: def_id)

    if %w[GovernmentBody Business].include?(name)
      RecalculateEntityLinkSubcategoriesJob.perform_later(id)
    end

    self
  end

  # Removes existing ExtensionRecord and associated model
  def remove_extension(name_or_id)
    name = name_or_id_to_name(name_or_id)
    # This func cannot be used to remove a primary extension
    raise ArgumentError if %w(None Org Person).include?(name)
    def_id = self.class.all_extension_names.index(name)
    extension_records.find_by_definition_id(def_id).try(:destroy)
    send(name.underscore).try(:destroy) if extension_with_fields?(name)

    if %w[GovernmentBody Business].include?(name)
      RecalculateEntityLinkSubcategoriesJob.perform_later(id)
    end

    self
  end

  # Merges extensions attributes for already existing extensions
  # This will only merge fields that are nil -- it won't update already existing fields
  # Example:
  #   If school.attributes['tuition'] => 'nil'
  #   then merge_extension('school', { tuition' => 20_000 }) will change
  #   the school tuition attribute to 20_000.
  #   However if school.attributes['tuition'] => 5_000, merge_extension('school', { tuition' => 20_000 }) will do nothing
  #   and school.attributes['tuition']  will remain at 5_000
  def merge_extension(name_or_id, fields)
    name = name_or_id_to_name(name_or_id)
    unless extension_with_fields?(name) && has_extension?(name)
      throw ArgumentError, "merge_extension can only be used with extensions that have fields"
    end
    extension = name.constantize.find_by_entity_id(id)

    update_attrs = ActiveSupport::HashWithIndifferentAccess
                          .new(fields)
                          .delete_if { |_, v| v.nil? }
                          .slice(*extension.attributes.select { |_, v| v.nil? }.keys)

    extension.update(update_attrs) unless update_attrs.empty?
    self
  end

  # Create new extension by definition ids
  # Accepts array of ids
  def add_extensions_by_def_ids(ids)
    ids.each { |def_id| add_extension(def_id) }
  end

  # Removes extensions by definition id
  def remove_extensions_by_def_ids(ids)
    ids.each { |def_id| remove_extension(def_id) }
  end

  def update_extension_records(def_ids)
    return nil unless def_ids.is_a? Array
    def_ids_to_delete = extension_ids_without_primary.delete_if { |x| def_ids.include?(x) }
    def_ids_to_create = def_ids.delete_if { |x| extension_ids_without_primary.include?(x) }
    add_extensions_by_def_ids(def_ids_to_create)
    remove_extensions_by_def_ids(def_ids_to_delete)
  end

  def extension_with_fields?(name)
    self.class.all_extension_names_with_fields.include?(name)
  end
end
