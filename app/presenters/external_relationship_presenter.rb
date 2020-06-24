# frozen_string_literal: true

class ExternalRelationshipPresenter < SimpleDelegator
  def data_summary
    @data_summary ||= _data_summary
  end

  def _data_summary
    if dataset == 'iapd_schedule_a'
      {
        'Name' => external_data.wrapper.format_name,
        'Acquired' => external_data.wrapper.min_acquired,
        'Title' => external_data.wrapper.title,
        'Advisor' => "#{OrgName.format(external_data.wrapper.advisor_name)} (#{external_data.wrapper.advisor_crd_number})"
      }
    else
      raise NotImplementedError
    end
  end

  def external_data_json
    JSON.pretty_generate external_data.data
  end
end
