# frozen_string_literal: true

# Object to hold information about each dataset. Used on the overview page  (/datasets)

class ExternalData
  Stats = Struct.new(:name, :description, :total, :matched, :unmatched, keyword_init: true) do
    def percent_matched
      ((matched / total.to_f) * 100).round(1)
    end

    def url
      Rails.application.routes.url_helpers.dataset_path(dataset: name, matched: 'unmatched')
    end
  end
end
