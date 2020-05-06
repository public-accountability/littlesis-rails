# frozen_string_literal: true

class ExternalEntityPresenter < SimpleDelegator
  # This returns a hash of useful information from
  # external dataset. It is displayed on the left-hands-side of
  # the entity matcher tool.
  def display_information
    return @display_information if defined?(@display_information)

    case dataset
    when 'iapd_advisors'
      @display_information = iapd_advisors_information
    else
      raise NotImplementedError
    end
  end

  private

  def iapd_advisors_information
    latest_filing = external_data.data.max_by { |h| h['filename'] }

    {
      'Name' => OrgName.format(latest_filing['name']),
      'CRD Number' => external_data.dataset_id,
      'SEC File Number' => latest_filing['sec_file_number'],
      'Assets under management' => latest_filing['assets_under_management'],
      'Latest filing date' => latest_filing['date_submitted']
    }
  end
end
