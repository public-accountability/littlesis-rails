# frozen_string_literal: true
module Sec
  FILING_FIELDS = %i[cik company_name form_type date_filed filename data db].freeze

  Filing = Struct.new(*FILING_FIELDS, :keyword_init => true) do
    def initialize(*args)
      super(*args)
      @url = "https://www.sec.gov/Archives/#{filename}"

      download_and_save_data(db) unless data.present?
    end

    def document
      @document ||= Sec::Document.new(form_type: form_type, data: data)
    end

    private

    def download_and_save_data(db)
      if (self.data = download)
        if db.nil?
          Rails.logger.warn('Sec::Filing') { 'Missing Database; not saving sec filing' }
        else
          db.insert_document(**to_h.slice(:filename, :data))
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
