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
           LINES TERMINATED BY '\\r\\n'
           (filer_id, report_id, transaction_code, e_year, transaction_id, @var1, @var2, contrib_code, contrib_type_code, corp_name, first_name, mid_init, last_name, address, city, state, zip, check_number, @var3, amount1, amount2, description, other_recpt_code, purpose_code1, purpose_code2, explanation, transfer_type, bank_loan_check_box, crerec_uid, @var4)
           SET created_at = CURRENT_TIMESTAMP,
               updated_at = CURRENT_TIMESTAMP,
               schedule_transaction_date = STR_TO_DATE(@var1, '%m/%d/%Y'),
               original_date = STR_TO_DATE(@var2, '%m/%d/%Y'),
               check_date = STR_TO_DATE(@var3, '%m/%d/%Y'),
               crerec_date = STR_TO_DATE(@var4, '%m/%d/%Y %T')"

    trim_data_sql = "DELETE FROM #{STAGING_TABLE_NAME} WHERE report_id NOT IN ('A', 'B', 'C', 'D')"
    puts "executing sql: \n\n#{load_data_sql}\n\n"
    ActiveRecord::Base.connection.execute(load_data_sql) unless dry_run
    puts "executing sql: \n\n#{trim_data_sql}\n\n"
    ActiveRecord::Base.connection.execute(trim_data_sql) unless dry_run
    puts "There are #{row_count} rows in #{STAGING_TABLE_NAME}"
  end

  def self.insert_new_disclosures(dry_run = false)
    puts "THIS IS A DRY RUN" if dry_run
    new_disclosures_count = 0
    existing_disclosures_skipped = 0
    NyDisclosure.find_by_sql("SELECT * from #{STAGING_TABLE_NAME}").each do |d|
      new_disclosure = d.dup # duplicate record from staging
      # look for existing disclosures
      nyd = NyDisclosure.find_by(
        filer_id: new_disclosure.filer_id,
        report_id: new_disclosure.report_id,
        transaction_code: new_disclosure.transaction_code,
        schedule_transaction_date: new_disclosure.schedule_transaction_date,
        e_year: new_disclosure.e_year
      )

      # if we couldn't find one, save the new one
      if nyd.nil?
        new_disclosure.save unless dry_run
        new_disclosures_count += 1
      else
        existing_disclosures_skipped += 1
      end
    end
    puts "Inserted #{new_disclosures_count} new disclosures into the database"
    puts "Skipped #{existing_disclosures_skipped} that already existed"
    puts "There are #{row_count} rows in #{STAGING_TABLE_NAME}"
  end
end
