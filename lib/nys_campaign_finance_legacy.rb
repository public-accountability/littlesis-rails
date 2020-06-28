# rubocop:disable Rails/Output
#
# solves some string encoding issues:
# ALTER TABLE ny_disclosures CONVERT TO CHARACTER SET 'utf8mb4' COLLATE 'utf8mb4_unicode_ci';
#
module NYSCampaignFinanceLegacy
  STAGING_TABLE_NAME = :ny_disclosures_staging

  def self.drop_staging_table
    ApplicationRecord.connection.execute("DROP TABLE IF EXISTS #{STAGING_TABLE_NAME}")
  end

  def self.create_staging_table
    ApplicationRecord.connection.create_table STAGING_TABLE_NAME do |t|
      t.string :filer_id, limit: 10, null: false
      t.string :report_id, limit: 1, null: false
      t.string :transaction_code, limit: 1, null: false
      t.string :e_year, limit: 4, null: false
      t.integer :transaction_id, limit: 8, null: false
      t.date :schedule_transaction_date, null: false
      t.date :original_date
      t.string :contrib_code, limit: 4
      t.string :contrib_type_code, limit: 1
      t.string :corp_name
      t.string :first_name
      t.string :mid_init
      t.string :last_name
      t.string :address
      t.string :city
      t.string :state, limit: 2
      t.string :zip, limit: 5
      t.string :check_number
      t.string :check_date
      t.float :amount1
      t.float :amount2
      t.string :description
      t.string :other_recpt_code
      t.string :purpose_code1
      t.string :purpose_code2
      t.string :explanation
      t.string :transfer_type, limit: 1
      t.string :bank_loan_check_box, limit: 1
      t.string :crerec_uid
      t.datetime :crerec_date

      t.timestamps
    end
  end

  def self.row_count
    ApplicationRecord.connection.execute("SELECT count(*) from #{STAGING_TABLE_NAME}").to_a[0][0]
  end

  def self.import_disclosure_data(file, dry_run = false)
    load_data_sql = "LOAD DATA LOCAL INFILE '#{Pathname.new(file).expand_path}'
           INTO TABLE #{STAGING_TABLE_NAME}
           FIELDS TERMINATED BY ',' ENCLOSED BY '\"'
           LINES TERMINATED BY '\\n'
           (filer_id, report_id, transaction_code, e_year, transaction_id, @var1, @var2, contrib_code, contrib_type_code, corp_name, first_name, mid_init, last_name, address, city, state, zip, check_number, @var3, amount1, amount2, description, other_recpt_code, purpose_code1, purpose_code2, explanation, transfer_type, bank_loan_check_box, crerec_uid, @var4)
           SET created_at = CURRENT_TIMESTAMP,
               updated_at = CURRENT_TIMESTAMP,
               schedule_transaction_date = STR_TO_DATE(@var1, '%m/%d/%Y'),
               original_date = STR_TO_DATE(@var2, '%m/%d/%Y'),
               check_date = STR_TO_DATE(@var3, '%m/%d/%Y'),
               crerec_date = STR_TO_DATE(@var4, '%m/%d/%Y %T')"

    trim_data_sql = "DELETE FROM #{STAGING_TABLE_NAME} WHERE transaction_code NOT IN ('A', 'B', 'C', 'D')"
    puts "executing sql: \n\n#{load_data_sql}\n\n"
    ApplicationRecord.connection.execute(load_data_sql) unless dry_run
    puts "executing sql: \n\n#{trim_data_sql}\n\n"
    ApplicationRecord.connection.execute(trim_data_sql) unless dry_run
    puts "There are #{row_count} rows in #{STAGING_TABLE_NAME}"
  end

  def self.limit_staging_to_years(years)
    years = years.map { |y| "'#{y}'" }.join(', ')
    in_year = ApplicationRecord.connection.execute("SELECT count(*) from #{STAGING_TABLE_NAME} where e_year IN (#{years})").to_a[0][0]

    puts "Found #{in_year} disclosures in years #{years}"
    puts "Preparing to delete all disclosures in #{STAGING_TABLE_NAME} that are NOT in years #{years}"
    ApplicationRecord.connection.execute("DELETE FROM #{STAGING_TABLE_NAME} WHERE e_year NOT IN (#{years})")
    puts "There are now #{row_count} rows in #{STAGING_TABLE_NAME}"
  end

  # Inserts disclosures from the staging table tht don't already exist
  def self.insert_new_disclosures(dry_run = false)
    puts "THIS IS A DRY RUN" if dry_run
    puts "There are #{row_count} rows in #{STAGING_TABLE_NAME}"
    puts "There are #{NyDisclosure.count} rows in ny_disclosures"

    # Skip index processing while importing data
    ThinkingSphinx::Callbacks.suspend!

    stats = { :new_disclosures_saved => 0, :invalid_new_disclosures => 0 }

    staging_disclosure_ids = staging_disclosures_to_add
    puts "There are #{staging_disclosure_ids.count} disclosures to add"
    puts "Skipping #{row_count - staging_disclosure_ids.count} disclosures that already exist"

    staging_disclosure_ids.each_with_index do |staging_id, idx|
      disclosure = NyDisclosure.find_by_sql("SELECT * FROM #{STAGING_TABLE_NAME} where id = #{staging_id} LIMIT 1")[0].dup
      if disclosure.valid?
        disclosure.delta = true # required by ThinkingSphinx; mysql will raise error unless this is set.
        disclosure.save unless dry_run
        stats[:new_disclosures_saved] += 1
      else
        stats[:invalid_new_disclosures] += 1
      end

      print "." if (idx % 5000).zero?
      print "\n #{(idx / Float(staging_disclosure_ids.count) * 100).round }% Complete\n" if (idx % 50_000).zero?
    end

    ThinkingSphinx::Callbacks.resume!
    puts "Inserted #{stats[:new_disclosures_saved]} new disclosures into the database"
    puts "Skipped #{stats[:invalid_new_disclosures]} invalid new disclosures"
    puts "There are now #{NyDisclosure.count} rows in ny_disclosures"
  end

  # -> Array of Ints
  def self.staging_disclosures_to_add
    ny_disclosures = Set.new
    staging_disclosure_ids = []

    years_in_staging = execute("SELECT distinct e_year FROM #{STAGING_TABLE_NAME}").to_a.flatten

    # get all existing nys disclosures
    execute("SELECT filer_id, report_id, transaction_id, schedule_transaction_date, e_year
             FROM ny_disclosures
             WHERE e_year IN #{Entity.sqlize_array(years_in_staging)}")
      .each(as: :hash) { |row| ny_disclosures << row }

    # loop through disclosures in staging table
    execute("SELECT id, filer_id, report_id, transaction_id, schedule_transaction_date, e_year
             FROM #{STAGING_TABLE_NAME}")
      .each(as: :hash) do |row|
        # if no match is found, add the id to the list of disclosure ids to add
        staging_disclosure_ids << row['id'] unless ny_disclosures.include?(row.except('id'))
      end

    staging_disclosure_ids
  end

  def self.insert_new_filers(file_path)
    puts "there are currently #{NyFiler.count} ny filers in the db"
    lines_with_errors = 0
    rows = []
    File.readlines(file_path).each do |line|
      begin
        rows << CSV.parse_line(line)
      rescue CSV::MalformedCSVError
        lines_with_errors += 1
      end
    end

    puts "there are #{lines_with_errors} errors"
    puts "there are #{rows.length} rows"

    new_filer_ids = rows.map { |r| r[0] }
    filer_ids_in_db = NyFiler.pluck(:filer_id)
    ids_to_add = new_filer_ids - filer_ids_in_db
    puts "there are #{ids_to_add.size} new rows to add"
    puts "adding new filers..."
    rows
      .select { |r| ids_to_add.include?(r[0]) }
      .map { |row| filer_row_to_h(row) }
      .each { |attr| NyFiler.create(attr) }
    puts "there are now #{NyFiler.count} ny filers in the db"
  end

  def self.filer_row_to_h(row)
    raise ArgumentError unless row.length == 13
    arr = row.map do |item|
      if item == '' || item == '\N'
        nil
      else
        item
      end
    end
    cols = [:filer_id, :name, :filer_type, :status, :committee_type, :office, :district, :treas_first_name, :treas_last_name, :address, :city, :state, :zip]
    h = cols.zip(arr).to_h
    h
  end

  private_class_method def self.execute(sql)
    ApplicationRecord.connection.execute(sql)
  end
end
# rubocop:enable Rails/Output
