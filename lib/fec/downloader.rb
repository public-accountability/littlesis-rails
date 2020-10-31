# frozen_string_literal: true

module FEC
  module Downloader
    def self.run
      FEC.loop_tables do |table|
        if File.exist? table.zip_localpath
          FEC.logger.info "FOUND: #{table.zip_localpath}"
        else
          begin
            IO.copy_stream URI.open(table.url), table.zip_localpath
            FEC.logger.info "SAVED: #{table.url} to #{table.zip_localpath}"
          rescue OpenURI::HTTPError
            FEC.logger.fatal "Failed to download #{table.url}"
            raise
          end
        end
      end
    end
  end
end
