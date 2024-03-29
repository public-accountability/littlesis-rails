# frozen_string_literal: true

module FEC
  module Cli
    def self.run
      create_directories
      Downloader.run
      CsvMaker.run
      Database.establish_connection
      Database.setup!
      Database.enable_dangerous_sqlite3_settings
      Importer.run
      DataCleaner.run
      Database.index!
      # Database.fulltext_index!
      Database.disable_dangerous_sqlite3_settings
    end

    def self.start
      OptionParser.new do |opts|
        opts.banner = "Usage: fec [options]"

        opts.on("--data-directory=DIR", "Directory to store downloaded data") do |x|
          FEC.configuration[:data_directory] = x
        end

        opts.on("--log=FILE", "Path to logfile") do |x|
          FEC.configuration[:logfile] = x
        end

        opts.on("--database=FILE", "Path to database. default: ./fec.rb") do |x|
          FEC.configuration[:database] = x
        end

        opts.on("--tables=TABLES", "comma separated list of tables to use") do |tables|
          FEC.configuration[:tables] = tables.split(',')
        end

        opts.on("--years=YEAR_MIN,YEAR_MAX", "Year range") do |years|
          if /\d{4}/.match? years
            FEC.configuration[:years] = [years.to_i]
          else
            FEC.configuration[:years] = Range.new(*years.split(',').map(&:to_i))
          end
        end

        # opts.on("--recheck", "Check for new data from FEC") do |x|
        # end

        opts.on("-h", "--help", "Prints this help") do
          puts opts
          exit
        end

        opts.on("--list", "list tables") do
          FEC.tables.map(&:name).sort.each { |name| puts name }
          exit
        end

        opts.on("--run", "Create fec sqlite database") do
          FEC.logger.info "CONFIGURATION: #{FEC.configuration.inspect}"
          FEC.logger.debug "RUN started"
          FEC::Cli.run
          FEC.logger.debug "RUN finished"
          exit
        end

        opts.on('--download', "Download files") do
          create_directories
          Downloader.run
        end

        opts.on('--make-csvs', "Create csvs") do
          create_directories
          CsvMaker.run
        end
      end.parse!
    end

    def self.create_directories
      FileUtils.mkdir_p File.join(FEC.configuration.fetch(:data_directory), "zip")
      FileUtils.mkdir_p File.join(FEC.configuration.fetch(:data_directory), "csv")
    end
  end
end
