# frozen_string_literal: true

class ExternalData < ApplicationRecord
  enum dataset: { reserved: 0,
                  iapd_advisors: 1,
                  iapd_owners: 2 }

  serialize :data

  def setup_data_column
    return self if data.present?

    case dataset
    when 'iapd_advisors', 'iapd_owners'
      self.data = []
    end

    self
  end
end
