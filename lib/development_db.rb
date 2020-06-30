# frozen_string_literal: true

# rubocop:disable Metrics/LineLength

class DevelopmentDb
  def initialize(path)
    @out_path = path
    @db = Rails.configuration.database_configuration['production']
  end

  def run
    create_clean_tables
    structure_only
    cleaned
    full_tables
    limit
  end

  def open_secrets
    cmd = "mysqldump -u #{@db['username']} -p#{@db['password']} -h #{@db['host']} --skip-comments --single-transaction #{@db['database']} #{OPEN_SECRETS.join(' ')} > #{@out_path}"
    `#{cmd}`
  end

  def create_clean_tables
    cmd = "mysql -u #{@db['username']} -p#{@db['password']} -h #{@db['host']} #{@db['database']} < #{Rails.root.join('lib', 'sql', 'clean_users.sql')}"
    `#{cmd}`
  end

  def full_tables
    cmd = "mysqldump -u #{@db['username']} -p#{@db['password']} -h #{@db['host']} --skip-comments --single-transaction #{@db['database']} #{FULL_DUMP.join(' ')} >> #{@out_path}"
    `#{cmd}`
  end

  def structure_only
    cmd = "mysqldump -u #{@db['username']} -p#{@db['password']} -h #{@db['host']} --no-data --single-transaction #{@db['database']} #{STRUCTURE.join(' ')} >> #{@out_path}"
    `#{cmd}`
  end

  def limit
    where = '--where="1 limit 5000"'
    cmd = "mysqldump -u #{@db['username']} -p#{@db['password']} -h #{@db['host']} --skip-comments --single-transaction #{where} #{@db['database']} #{LIMIT.join(' ')} >> #{@out_path}"
    `#{cmd}`
  end

  def cleaned
    CLEANED.each { |table| dump_clean_table(table) }
  end

  def dump_clean_table(clean_name)
    normal_name = clean_name.gsub('clean_', '')
    sed = "sed 's/#{clean_name}/#{normal_name}/g'"
    cmd = "mysqldump -u #{@db['username']} -p#{@db['password']} -h #{@db['host']} --skip-comments --single-transaction #{@db['database']} #{clean_name} | #{sed} >> #{@out_path}"
    `#{cmd}`
  end

  # All tables can be grouped in to 4 categories for export
  #  1) Tables who'se entire contents can be dumped (i.e. entities)
  #  2) Table where just the structure needs to exported (i.e. sessions)
  #  3) Tables containing senstive information that must be cleaned first (i.e. users)
  #  4) Large tables that can be dumpt with LIMIT in order to reduce the export size (i.e. os_donations)

  FULL_DUMP = %w[address
                 address_category
                 address_country
                 address_state
                 alias
                 article
                 article_entities
                 article_entity
                 article_source
                 articles
                 business
                 business_industry
                 business_person
                 candidate_district
                 cmp_entities
                 cmp_relationships
                 common_names
                 couple
                 custom_key
                 dashboard_bulletins
                 degree
                 documents
                 donation
                 education
                 elected_representative
                 email
                 entity
                 entity_fields
                 extension_definition
                 extension_record
                 external_links
                 family
                 fields
                 generic
                 government_body
                 help_pages
                 hierarchy
                 image
                 industries
                 industry
                 link
                 lobby_filing
                 lobby_filing_lobby_issue
                 lobby_filing_lobbyist
                 lobby_filing_relationship
                 lobby_issue
                 lobbying
                 lobbyist
                 ls_list
                 ls_list_entity
                 membership
                 network_map
                 ny_filer_entities
                 org
                 os_category
                 ownership
                 pages
                 person
                 phone
                 political_candidate
                 political_district
                 political_fundraising
                 political_fundraising_type
                 position
                 professional
                 public_company
                 references
                 relationship
                 relationship_category
                 representative
                 representative_district
                 schema_migrations
                 school
                 social
                 tag
                 tags
                 taggings
                 toolkit_pages
                 transaction
                 user_permissions].freeze

  STRUCTURE = %w[api_request
                 api_user
                 api_tokens
                 chat_user
                 delayed_jobs
                 edited_entities
                 external_data
                 external_entities
                 external_relationships
                 map_annotations
                 ny_disclosures
                 ny_filers
                 ny_matches
                 object_tag
                 sessions
                 sphinx_index
                 user_requests
                 versions
                 unmatched_ny_filers].freeze

  NON_CLEANED_IGNORED = %w[user_profiles users].freeze

  CLEANED = %w[clean_user_profiles clean_users].freeze

  LIMIT = %w[modification
             modification_field
             os_candidates
             os_committees
             os_donations
             os_entity_category
             os_entity_donor
             os_matches
             reference
             reference_excerpt].freeze

  OPEN_SECRETS = %w[os_candidates os_committees os_donations os_entity_category os_entity_donor os_matches].freeze

  # these tables need to be cleaned afterwards:
  # entity, alias, relationship, extension_record,
  # link, taggings, taggings
  # see: clean_public_data.sql
  PUBLIC_DATA = %w[
    alias
    business
    business_industry
    business_person
    candidate_district
    couple
    degree
    donation
    education
    elected_representative
    entity
    extension_definition
    extension_record
    external_links
    family
    generic
    government_body
    hierarchy
    industries
    industry
    link
    lobbyist
    membership
    org
    ownership
    person
    political_candidate
    political_district
    political_fundraising
    political_fundraising_type
    position
    professional
    public_company
    relationship_category
    representative
    representative_district
    school
    social
    tags
    taggings
    transaction
    entity
    relationship
    references
    documents
  ].freeze
end

# rubocop:enable Metrics/LineLength
