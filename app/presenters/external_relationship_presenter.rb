# frozen_string_literal: true

class ExternalRelationshipPresenter < SimpleDelegator
  def data_summary
    if dataset == 'iapd_schedule_a'
      @data_summary ||= {
        'Name' => schedule_a_records.last['name'],
        'Acquired' => LsDate.parse(schedule_a_records.map { |r| r['acquired'] }.min).to_s,
        'Title' => schedule_a_records.last['title_or_status'],
        'Advisor' => "#{OrgName.format(external_data.data['advisor_name'])} (#{external_data.data['advisor_crd_number']})"
      }
    else
      raise NotImplementedError
    end
  end

  def external_data_json
    JSON.pretty_generate external_data.data
  end
end
