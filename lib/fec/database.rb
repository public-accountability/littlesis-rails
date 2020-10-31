# frozen_string_literal: true

module FEC
  module Database
    def self.establish_connection
      return if ActiveRecord::Base.connected?

      unless File.exist?(FEC.configuration[:database])
        FEC.logger.warn "#{FEC.configuration[:database]} is missing. Creating a new file."
      end

      ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: FEC.configuration[:database])
    end

    def self.setup!
      FEC.logger.info "SETUP: creating tables"
      execute_sql_file(File.join(__dir__, './schema.sql'))
      execute_sql_file(File.join(__dir__, './index.sql'))
    end

    # Runs sqlite3 as an external program
    def self.execute(sql)
      Open3.popen2e "sqlite3 #{FEC.configuration[:database]}" do |stdin, stdout_and_stderr|
        stdin.print sql
        stdin.close
        stdout_and_stderr.read.split("\n").each { |x| FEC.logger.debug "SQLITE: #{x}" }
      end
    end

    # Uses ActiveRecord::Base.connection
    def self.exec_query(*args)
      ActiveRecord::Base.connection.exec_query(*args)
    end

    def self.execute_sql_file(path)
      File.read(path).split(';').each do |sql|
        execute(sql)
      end
    end

    def self.row_count(table)
      exec_query("SELECT COUNT(*) AS c FROM #{table}").first.fetch('c')
    end
  end
end
