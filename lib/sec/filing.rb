# frozen_string_literal: true

module Sec
  class Filing
    attr_reader :form_type,
                :date_filed,
                :filename,
                :data,
                :cik,
                :url

    def initialize(form_type:, date_filed:, filename:, cik:, data:, db: nil)
      @form_type = form_type
      @date_filed = date_filed
      @filename = filename
      @url = "https://www.sec.gov/Archives/#{filename}"
      @cik = cik

      download_and_save_data(db) unless (@data = data)
    end

    private

    def download_and_save_data(db)
      if (@data = download)
        if db.nil?
          Rails.logger.warn('Sec::Filing') { "Missing Database; not saving sec filing" }
        else
          db.insert_document(filename: @filename, data: @data)
        end
      end
    end

    def download
      Rails.logger.debug('Sec::Filing') { "Downloading #{@url}" }
      res = HTTParty.get(@url, headers: { 'User-Agent' => '' })
      if res.success?
        res.body
      else
        Rails.logger.warn('Sec::Filing') { "failed to download #{@url}" }
        nil
      end
    end 
  end
end
