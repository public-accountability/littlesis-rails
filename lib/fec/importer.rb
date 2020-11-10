# frozen_string_literal: true

module FEC
  module Importer
    def self.run
      FEC.loop_tables do |table|
        FEC.logger.info "IMPORTING #{table.csv_localpath}"

        Database.execute <<~SQL
         .mode csv
         .import #{table.csv_localpath} #{table.name}
        SQL
      end
    end
  end
end
