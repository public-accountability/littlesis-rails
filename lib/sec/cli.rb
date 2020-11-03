# frozen_string_literal: true

# rubocop:disable Rails/Output

# Examples Commands:
#     sec --print-forms=3,4,8K --cik 0000019617
#     sec --roster --cik 0000019617
#     sec --list-example-ciks
#     sec --cik 0000019617 --relationships
#     sec --cik 0000019617 --relationships --json
module SEC
  class Cli
    def self.start
      new
    end

    def initialize
      run(parse_options)
    end

    def parse_options
      options = {
        forms: %w[3 4 5]
      }.with_indifferent_access

      OptionParser.new do |opts|
        opts.banner = 'Usage: sec [options]'

        opts.on('--roster', 'output a list roster of names found on filings')
        opts.on('--print-forms', 'output list of forms')
        opts.on('--list-example-ciks', 'print list of example ciks to use')
        opts.on('--top-companies', 'generates csv for all top companies')
        opts.on('--relationships', 'outputs tsv of relationships')

        # CIK is required with --roster, --print-forms  and --relationships
        opts.on('--cik CIK', "The company's CIK number")

        # formatting options
        opts.on('--forms [FORMS]', Array, 'comma separated list of forms')
        opts.on('--json', 'outputs json instead of tsv')
        opts.on('--path [DATABASE]', 'path to sec filings database')
      end.parse!(into: options)

      if options[:cik]
        if /\A[A-Z]+\Z/.match?(options[:cik])
          options[:cik] = Sec::CIKS.fetch(options[:cik])
        else
          options[:cik] = options[:cik].rjust(10, '0')
        end
      end

      options
    end

    def run(options)
      if options['list-example-ciks']
        Sec::CIKS.each { |ticker, cik| puts "#{ticker}\t#{cik}" }
        return
      end

      db = Sec::Database.new(options.slice(:forms, :path))

      if options['top-companies']
        top_companies db: db, json: options[:json]
        return
      end

      requires_cik! options[:cik]

      if options['print-forms']
        print_forms(db, options)
      elsif options['roster']
        roster(db, options)
      elsif options['relationships']
        relationships(db, options)
      end

    ensure
      db.close if defined?(db) && db.present?
    end

    def print_forms(db, options)
      forms = db.forms(cik: options[:cik], form_types: options[:forms])
      self.class.print(forms, fields: %i[form_type date_filed filename])
    end

    def roster(db, options)
      roster = db.company(options[:cik]).roster
      if options[:json]
        puts JSON.pretty_generate(roster.to_h)
      else
        self.class.print(roster.spreadsheet)
      end
    end

    def relationships(db, options)
      cik = options[:cik]
      entity = ExternalLink.find_by_cik(cik).entity

      relationships = Sec::Importer
                        .new(entity, db: db)
                        .relationships
                        .map { |r| Sec::Relationship.format(r) }

      if options[:json]
        puts JSON.pretty_generate(relationships)
      else
        self.class.print(relationships)
      end
    end

    def top_companies(db:, json: false)
      amount = 50
      format = json ? :json : :csv
      filename = Rails.root.join('data', "top_companies_#{Time.current.strftime('%F')}.#{format}").to_s
      file = File.new(filename, 'w')

      ColorPrinter.print_blue "Saving top companies to #{filename}"

      file << Sec::Relationship.csv_headers if format == :csv
      file << "[\n" if format == :json

      # `Sec.top_companies` returns entities that have CIK numbers
      Sec.top_companies(amount).each do |company|
        ColorPrinter.print_gray "processing: #{company.name_with_id}"
        # Calculates an array of relationships for each company. This can take a while
        # because it may have to download documents from the SEC website and/or
        # find matching people using `EntityMatcher`
        Sec::Importer.new(company, db: db).relationships.each do |relationship|
          # Writes either a CSV row or a JSON string
          file << Sec::Relationship.public_send(format, relationship)
          file << ",\n" if format == :json
        end
      end

      if format == :json
        # Erase the trailing comma and new line and replace with closing bracket.
        file.seek(-2, :CUR)
        file << "\n]"
      end
    ensure
      file.close
    end

    def requires_cik!(cik)
      raise ArgumentError, "Please provide a CIK number" unless cik
    end

    def self.print(rows, sep: "\t", fields: nil)
      headers = (fields.presence || rows.first.keys).map(&:to_sym)

      puts headers.join(sep)

      rows.each do |r|
        puts r.to_h.symbolize_keys.values_at(*headers).join(sep)
      end
    end
  end
end

# rubocop:enable Rails/Output
