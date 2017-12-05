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

  FULL_DUMP = %w( address
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
                  couple
                  custom_key
                  degree
                  documents
                  domain
                  donation
                  education
                  elected_representative
                  email
                  entity
                  entity_fields
                  extension_definition
                  extension_record
                  external_key
                  family
                  fec_filing
                  fedspending_filing
                  fields
                  gender
                  generic
                  government_body
                  group_lists
                  group_users
                  groups
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
                  sf_guard_group
                  sf_guard_group_list
                  sf_guard_group_permission
                  sf_guard_permission
                  sf_guard_user_group
                  sf_guard_user_permission
                  social
                  tag
                  tags
                  taggings
                  toolkit_pages
                  transaction
                  user_permissions)

  STRUCTURE = %w( api_request
                  api_user
                  chat_user
                  delayed_jobs
                  map_annotations
                  object_tag
                  os_entity_preprocess
                  os_entity_transaction
                  queue_entities
                  scheduled_email
                  scraper_meta
                  sessions
                  sf_guard_remember_key
                  sphinx_index
                  task_meta
                  versions  )

  NON_CLEANED_IGNORED = %w(sf_guard_user sf_guard_user_profile users)

  CLEANED = %w(clean_sf_guard_user clean_sf_guard_user_profile clean_users)

  LIMIT = %w( modification
              modification_field
              note
              note_entities
              note_groups
              note_lists
              note_networks
              note_relationships
              note_users
              ny_disclosures
              ny_filers
              ny_matches
              os_candidates
              os_committees
              os_donations
              os_entity_category
              os_entity_donor
              os_matches
              reference
              reference_excerpt)

  PUBLIC_DATA = [
    'alias',
    'business',
    'business_industry',
    'business_person',
    'candidate_district',
    'couple',
    'degree',
    'donation',
    'education',
    'elected_representative',
    'entity',
    'entity_fields',
    'extension_definition',
    'extension_record',
    'family',
    'fields',
    'gender',
    'generic',
    'government_body',
    'hierarchy',
    'industries',
    'industry',
    'link',
    'lobby_filing',
    'lobby_filing_lobby_issue',
    'lobby_filing_lobbyist',
    'lobby_filing_relationship',
    'lobby_issue',
    'lobbying',
    'lobbyist',
    'membership',
    'org',
    'ownership',
    'person',
    'political_candidate',
    'political_district',
    'political_fundraising',
    'political_fundraising_type',
    'position',
    'professional',
    'public_company',
    'relationship_category',
    'representative',
    'representative_district',
    'school',
    'social',
    'transaction',
    # these tables need to be cleaned afterwards
    'entity',
    'relationship',
    'reference',
    'reference_excerpt'
  ]
end
