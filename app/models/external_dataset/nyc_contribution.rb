# frozen_string_literal: true

module ExternalDataset
  # NOTE: currently hard-coded to use 2021's data
  class NYCContribution < ApplicationRecord
    extend DatasetInterface
    self.dataset = :nyc_contributions

    SOURCE_URL = "https://nyccfb.info/DataLibrary/2021_Contributions.csv"
    LOCALPATH = ROOT_DIR.join('original', '2021_Contributions.csv').to_s.freeze
    CSVPATH = ROOT_DIR.join('2021_Contributions.csv').to_s.freeze

    def self.create_table
      connection.create_table(table_name) do |t|
        t.integer :election, limit: 2
        t.string :officecd, limit: 2
        t.text :recipid
        t.string :canclass
        t.text :recipname
        t.text :committee
        t.integer :filing, limit: 1
        t.text :schedule
        t.decimal :pageno
        t.decimal :sequenceno
        t.string :refno
        t.date :date
        t.date :refunddate
        t.text :name
        t.text :c_code
        t.text :strno
        t.text :strname
        t.text :apartment
        t.string :boroughcd, limit: 1
        t.text :city
        t.text :state
        t.text :zip
        t.text :occupation
        t.text :empname
        t.text :empstrno
        t.text :empstrname
        t.text :empcity
        t.text :empstate
        t.decimal :amnt, scale: 2, precision: 15
        t.decimal :matchamnt
        t.decimal :prevamnt
        t.integer :pay_method, limit: 1
        t.text :intermno
        t.text :intermname
        t.text :intstrno
        t.text :intstrnm
        t.text :intaptno
        t.text :intcity
        t.text :intst
        t.text :intzip
        t.text :intempname
        t.text :intempstno
        t.text :intempstnm
        t.text :intempcity
        t.text :intempst
        t.text :intoccupa
        t.text :purposecd
        t.text :exemptcd
        t.text :adjtypecd
        t.text :rr_ind
        t.text :seg_ind
        t.text :int_c_code
      end
    end

    def self.download
      Utility.stream_file_if_not_exists(url: SOURCE_URL, path: LOCALPATH)
    end

    def self.extract
      CSV.open(CSVPATH, 'w') do |outcsv|
        CSV.foreach(LOCALPATH, headers: true) do |row|
          row['DATE'] = format_date(row['DATE'])
          row['REFUNDDATE'] = format_date(row['REFUNDDATE'])
          outcsv << row
        end
      end
    end

    def self.load
      run_query <<~SQL
        COPY #{table_name} (ELECTION,OFFICECD,RECIPID,CANCLASS,RECIPNAME,COMMITTEE,FILING,SCHEDULE,PAGENO,SEQUENCENO,REFNO,DATE,REFUNDDATE,NAME,C_CODE,STRNO,STRNAME,APARTMENT,BOROUGHCD,CITY,STATE,ZIP,OCCUPATION,EMPNAME,EMPSTRNO,EMPSTRNAME,EMPCITY,EMPSTATE,AMNT,MATCHAMNT,PREVAMNT,PAY_METHOD,INTERMNO,INTERMNAME,INTSTRNO,INTSTRNM,INTAPTNO,INTCITY,INTST,INTZIP,INTEMPNAME,INTEMPSTNO,INTEMPSTNM,INTEMPCITY,INTEMPST,INTOCCUPA,PURPOSECD,EXEMPTCD,ADJTYPECD,RR_IND,SEG_IND,INT_C_CODE)
        FROM '#{CSVPATH.gsub("/littlesis", "")}' WITH CSV;
      SQL
    end

    private_class_method def self.format_date(d)
      return nil if d.blank?

      Date.strptime(d, '%m/%d/%Y').strftime('%F')
    end
  end
end
