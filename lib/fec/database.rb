# frozen_string_literal: true

module FEC
  module Database
    def self.connection
      FEC::ApplicationRecord.connection
    end

    def self.connected?
      connection&.adapter_name == 'SQLite'
    rescue Mysql2::Error::ConnectionError
      false
    end

    def self.establish_connection
      return connection if connected?

      unless File.exist?(FEC.configuration[:database])
        FEC.logger.warn "#{FEC.configuration[:database]} is missing. Creating a new file."
      end

      FEC::ApplicationRecord.establish_connection(adapter: 'sqlite3', database: FEC.configuration[:database])
    end

    def self.enable_dangerous_sqlite3_settings
      connection.exec_query "PRAGMA synchronous=OFF"
      connection.exec_query "PRAGMA journal_mode=OFF"
    end

    def self.disable_dangerous_sqlite3_settings
      connection.exec_query "PRAGMA synchronous=NORMAL"
      connection.exec_query "PRAGMA journal_mode=WAL"
    end

    def self.setup!
      FEC.logger.info 'SETUP: creating tables'
      execute_sql_file(File.join(__dir__, './schema.sql'))
    end

    def self.index!
      FEC.logger.info 'SETUP: creating indexes'
      execute_sql_file(File.join(__dir__, './index.sql'))
    end

    def self.fulltext_index!
      FEC.logger.info 'SETUP: creating fulltext indexes'
      execute_sql_file(File.join(__dir__, './fulltext.sql'))
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
      connection.exec_query(*args)
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
