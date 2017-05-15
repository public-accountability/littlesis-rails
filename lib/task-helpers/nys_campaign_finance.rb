module NYSCampaignFinance
  STAGING_TABLE_NAME = :ny_disclosures_staging

  def self.drop_staging_table
    ActiveRecord::Base.connection.execute("DROP TABLE IF EXISTS #{STAGING_TABLE_NAME}")
  end

  def self.create_staging_table
    ActiveRecord::Base.connection.create_table STAGING_TABLE_NAME do |t|
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
    ActiveRecord::Base.connection.execute("SELECT count(*) from #{STAGING_TABLE_NAME}").to_a[0][0]
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
    ActiveRecord::Base.connection.execute(load_data_sql) #unless dry_run
    puts "executing sql: \n\n#{trim_data_sql}\n\n"
    ActiveRecord::Base.connection.execute(trim_data_sql) #unless dry_run
    puts "There are #{row_count} rows in #{STAGING_TABLE_NAME}"
  end

  # loops through all dislocsures in the staging table
  # determining if they are new and inserts the new
  # disclosures in to the regular ny_disclosures table
  def self.insert_new_disclosures(dry_run = false)
    puts "THIS IS A DRY RUN" if dry_run
    puts "There are #{row_count} rows in #{STAGING_TABLE_NAME}"
    puts "There are #{NyDisclosure.count} rows in ny_disclosures"

    # Skip index processing while importing data
    ThinkingSphinx::Callbacks.suspend!

    stats = {
      :new_disclosures_saved => 0,
      :invalid_new_disclosures => 0,
      :existing_disclosures_skipped => 0
    }

    offset = 0
    complete = false
    until complete
      batch = get_staging_batch(offset)
      offset += 2000
      complete = true if batch.size.zero?
      import_disclosure_batch(batch, stats, dry_run)
      print_stats(offset, stats)
    end

    ThinkingSphinx::Callbacks.resume!
    puts "Inserted #{stats[:new_disclosures_saved]} new disclosures into the database"
    puts "Skipped #{stats[:existing_disclosures_skipped]} that already exist"
    puts "Skipped #{stats[:invalid_new_disclosures]} invalid new disclosures"
    puts "There are now #{NyDisclosure.count} rows in ny_disclosures"
  end

  # We are looping through the disclosures in batches of 2000
  # in order to limit memory usege
  def self.get_staging_batch(offset)
    # This is something of ActiveRecord hack.
    # We are instantiating versions of NyDisclosures from
    # the staging stable instead of from the normal table.
    NyDisclosure.find_by_sql("SELECT * FROM #{STAGING_TABLE_NAME} ORDER BY id ASC LIMIT 2000 OFFSET #{offset}")
  end

  # [ <NyDisclosure> ], Hash -> 
  def self.import_disclosure_batch(batch, stats, dry_run = false)
    batch.each do |d|
      # these are shadow NyDisclosures, created from
      # the staging table, so we need to duplicate them
      # in order for ActiveRecord not to get confused
      new_disclosure = d.dup
      if new_disclosure.valid?

        # look for existing disclosures
        nyd = NyDisclosure.find_by(
          filer_id: new_disclosure.filer_id,
          report_id: new_disclosure.report_id,
          transaction_id: new_disclosure.transaction_id,
          transaction_code: new_disclosure.transaction_code,
          schedule_transaction_date: new_disclosure.schedule_transaction_date,
          e_year: new_disclosure.e_year
        )

        # if we couldn't find one, save the new one
        if nyd.nil?
          new_disclosure.delta = true # required by ThinkingSphinx; mysql will raise error unless this is set.
          new_disclosure.save unless dry_run
          stats[:new_disclosures_saved] += 1
        else
          stats[:existing_disclosures_skipped] += 1
        end

      # the new disclosure isn't valid
      else
        puts "Invalid disclosure: #{new_disclosure.errors.full_messages.join(',')}"
        puts "\n#{new_disclosure.attributes.to_json}\n"
        stats[:invalid_new_disclosures] += 1
      end
    end # end loop through batch
  end

  def self.print_stats(offset, stats)
    pp(stats) if (offset % 20000).zero?
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
end
