# frozen_string_literal: true

# rubocop:disable Rails/Output

module Sec
  class Cli
    def initialize
      run(parse_options)
    end

    def parse_options
      options = {
        forms: %w[3 4]
      }.with_indifferent_access

      OptionParser.new do |opts|
        opts.banner = 'Usage: sec [options]'

        opts.on('--roster', 'output a list roster of names found on filings')
        opts.on('--print-forms', 'output list of forms')
        opts.on('--list-example-ciks', 'print list of example ciks to use')

        # CIK is required with --roster and --print-forms
        opts.on('--cik CIK', "The company's CIK number")

        # formatting options
        opts.on('--forms [FORMS]', Array, 'comma separated list of forms')
        opts.on('--json', 'outputs json (when combined with --roster)')
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
      end

      requires_cik! options[:cik]

      db = Sec::Database.new(options.slice(:forms, :path))

      if options['print-forms']
        print_forms(db, options)
      elsif options['roster']
        roster(db, options)
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
      puts JSON.pretty_generate(roster)
      #   if options[:json]
      #     puts JSON.pretty_generate(roster)
      #   else
      #     spreadsheet = roster.spreadsheet

      #     puts spreadsheet.first.keys.join("\t")
      #     spreadsheet.each { |x| puts x.values.join("\t") }
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
