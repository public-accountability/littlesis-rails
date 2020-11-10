# frozen_string_literal: true

module FEC
  module Importer
    def self.run
      FEC.loop_tables do |table|
        if table_empty?(table)
          FEC.logger.info "IMPORTING #{table.csv_localpath}"

          Database.execute <<~SQL
            .mode csv
            .import #{table.csv_localpath} #{table.name}
           SQL
        else
          FEC.logger.info "SKIPPING #{table.csv_localpath} because #{table.name} is not empty"
        end
      end
    end

    private_class_method def self.table_empty?(table)
      FEC::Database.exec_query("SELECT COUNT(*) from #{table.name}").rows.first.first.zero?
    end
  end
end
