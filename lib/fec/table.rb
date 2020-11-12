# frozen_string_literal: true

module FEC
  Table = Struct.new(:name, :filename, :header, :description, :year, keyword_init: true) do
    def url
      "https://www.fec.gov/files/bulk-downloads/#{year}/#{zip_filename}"
    end

    def zip_localpath
      File.join FEC.configuration.fetch(:data_directory), "zip", zip_filename
    end

    def csv_localpath
      File.join FEC.configuration.fetch(:data_directory), "csv", csv_filename
    end

    def zip_filename
      slug + ".zip"
    end

    def csv_filename
      slug + ".csv"
    end

    def slug
      filename + short_year
    end

    def short_year
      year.to_s.slice(2, 4)
    end

    # This is the name of the text file that's inside the zip file
    def zip_entry
      case name
      when 'candidates_summaries', 'pac_summaries', 'congress_current_campaigns'
        slug + ".txt"
      when 'candidates', 'candidate_committee_linkages', 'committees'
        filename + ".txt"
      when 'individual_contributions'
        'itcont.txt'
      when 'committee_contributions'
        'itpas2.txt'
      when 'transactions'
        'itoth.txt'
      when 'operating_expenditures'
        'oppexp.txt'
      else
        raise StandardError, "Invalid table name: #{table}"
      end
    end
  end
end
