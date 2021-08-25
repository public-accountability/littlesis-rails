# frozen_string_literal: true

module SEC
  class Filing
    class MissingDocumentError < StandardError; end

    # Input: string (url)
    # output: string OR nil
    def self.download(url)
      Rails.logger.debug('SEC::Filing') { "Downloading #{url}" }
      res = Net::HTTP.get_response(URI(url), { 'User-Agent' => '' })

      if res.is_a?(Net::HTTPSuccess)
        res.body
      else
        Rails.logger.warn('SEC::Filing') { "failed to download #{url}" }
        nil
      end
    end

    attr_reader :metadata, :data, :document, :url
    attr_accessor :download, :db

    # There is no validation done here, but it is assumed that metadata is hash-like
    # with the following keys: cik, company_name, form_type, date_filed, filename, data
    def initialize(metadata:, data: nil, db: nil, download: true)
      @metadata = metadata.symbolize_keys
      @data = data
      @url = "https://www.sec.gov/Archives/#{@metadata.fetch(:filename)}"
      @db = db
      @download = download
      set_document
    end

    def type
      @metadata.fetch(:form_type)
    end

    # -> [{}]
    def reporting_owners
      raise MissingDocumentError if @data.blank?

      document.reporting_owners.map do |reporting_owner|
        reporting_owner
          .to_h
          .with_indifferent_access
          .merge(filename: @metadata.fetch(:filename),
                 date_filed: @metadata.fetch(:date_filed))
      end
    end

    # This returns a hash with two fields: metadata & document
    # Both are hashes. `@data` is not included because the parsed data
    # is what constitutes `document`
    def to_h
      download_and_save_data if @download
      raise MissingDocumentError if @data.blank?

      {
        metadata: @metadata,
        document: @document.to_h
      }
    end

    alias to_hash to_h

    def download_and_save_data
      return if @data

      if (@data = self.class.download(@url))
        set_document

        if db.nil?
          Rails.logger.warn('SEC::Filing') { 'Missing Database; not saving sec filing' }
        else
          db.insert_document(filename: @metadata[:filename], data: @data)
        end
      end
    end

    private

    def set_document
      return unless @data

      @document = SEC::Document.new(@data)
    end
  end
end
