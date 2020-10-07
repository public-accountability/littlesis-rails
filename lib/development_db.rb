# frozen_string_literal: true

# rubocop:disable Metrics/LineLength

class DevelopmentDb
  # Groupings of tables in our database
  # :system tables where only the table structure is dumped (a CREATE TABLE statement but without any data)
  #     These either contain production data unneccessary for development (i.e. delayed_jobs) or are very large (i.e. external_data)
  # :public is the core LittleSis dataset, although there is still another processing step before it can be distruputed
  TABLES = Struct.new(:all, :system, :open_secrets, :nys_campaign_finance, :external_data, :legacy, :users, :structure, :development, :public)

  def self.tables
    @tables ||= TABLES.new.tap do |tables|
      tables.all = ActiveRecord::Base.connection.tables.freeze
      tables.system = %w[api_tokens delayed_jobs edited_entities object_tag sphinx_index user_requests versions web_requests user_permissions permission_passes].freeze
      tables.open_secrets = %w[os_matches os_candidates os_committees os_donations os_entity_category os_entity_donor].freeze
      tables.nys_campaign_finance = %w[ny_disclosures ny_filer_entities ny_filers unmatched_ny_filers ny_matches].freeze
      tables.external_data = %w[external_data external_entities external_relationships].freeze
      tables.legacy = %w[modification modification_field reference reference_excerpt].freeze
      tables.users = %w[user_profiles users].freeze
      tables.structure = (tables.system + tables.open_secrets + tables.nys_campaign_finance + tables.external_data).freeze
      tables.development = (tables.all - tables.structure - tables.users - tables.legacy).freeze
      tables.public = %w[alias business business_industry business_person common_names degree documents donation education
                         elected_representative entity extension_definition extension_record external_links family generic
                         government_body hierarchy link lobbyist membership org ownership person political_candidate
                         political_fundraising position professional public_company references relationship relationship_category
                         school social taggings tags transaction].freeze
    end.freeze
  end

  delegate :tables, :to => :class

  def initialize(type, debug: false)
    @type = type
    @debug = debug

    unless %i[development public open_secrets external_data].include?(@type)
      raise Exceptions::LittleSisError, 'Invalid DevelopmentDb Type'
    end

    @dbconfig = Rails.configuration.database_configuration.fetch(Rails.env)
  end

  def run
    case @type
    when :development
      dump_user_tables
      execute mysqldump(tables.development)
      execute mysqldump(tables.structure, no_data: true)
    when :open_secrets
      execute mysqldump(tables.open_secrets)
    when :external_data
      execute mysqldump(tables.external_data)
    when :public
      execute mysqldump(tables.public)
    end
  end

  private

  def execute(cmd)
    cmd += " >> #{filepath}"

    if @debug
      puts cmd
    else
      system cmd, exception: true
    end
  end

  def mysqldump(tables, no_data: false)
    cmd = "mysqldump -u #{@dbconfig['username']} -p#{@dbconfig['password']} -h #{@dbconfig['host']}"
    cmd += ' --single-transaction --skip-lock-tables --quick'
    cmd += ' --no-data' if no_data
    cmd += " #{@dbconfig['database']}"
    cmd += " #{Array.wrap(tables).join(' ')}"
    cmd
  end

  def dump_user_tables
    Utility.execute_sql_file Rails.root.join('lib', 'sql', 'clean_users.sql') # creates clean_users and clean_user_profiles

    tables.users.each do |table|
      clean_name = "clean_#{table}"
      # hack to export "clean_user_profiles" as "user_profiles"
      sed = "sed 's/#{clean_name}/#{table}/g'"
      execute " #{mysqldump(clean_name)} | #{sed}"
    end
  end

  def filepath
    case @type
    when :development
      Rails.root.join('data', "development_db#{LsDate.today}.sql")
    when :open_secrets
      Rails.root.join('data', "open_secrets#{LsDate.today}.sql")
    when :external_data
      Rails.root.join('data', "external_data#{LsDate.today}.sql")
    when :public
      Rails.root.join('data', "public_data_raw#{LsDate.today}.sql")
    end
  end
end

# rubocop:enable Metrics/LineLength
