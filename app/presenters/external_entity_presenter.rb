# frozen_string_literal: true

class ExternalEntityPresenter < SimpleDelegator
  # This returns a hash of useful information from external dataset.
  # It is displayed on the left-hands-side of the entity matcher tool.
  def display_information
    return @display_information if defined?(@display_information)

    case dataset
    when 'iapd_advisors'
      @display_information = iapd_advisors_information
    when 'nycc'
      @display_information = nycc_information
    when 'nys_filer'
      @display_information = external_data
                               .wrapper
                               .nice
                               .slice(:filer_id, :name, :status, :office, :address)
                               .transform_keys { |k| k.to_s.tr('_', ' ').capitalize }
    else
      raise NotImplementedError
    end
  end

  private

  def nycc_information
    data = external_data.data
    {
      'Name' => data['FullName'],
      'Party' => data['Party'],
      'District' => data['District'],
      'Website' => data['Website'],
      'Office Address' => data['DistrictOfficeAddress'],
      'Email' => data['Email']
    }
  end

  def iapd_advisors_information
    data = external_data.data
    {
      'Name' => OrgName.format(data['names'].first),
      'CRD Number' => external_data.dataset_id,
      'SEC File Number' => data['sec_file_numbers'].first,
      'Assets under management' => ActiveSupport::NumberHelper.number_to_human(data['latest_aum']),
      'Latest filing date' => data['latest_date_submitted']
    }
  end
end
