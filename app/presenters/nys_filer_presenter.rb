# frozen_string_literal: true

class NYSFilerPresenter < SimpleDelegator
  def presentation_attributes
    {
      'Name' => filer_name,
      'ID' => filer_id,
      'Type' => committee_type_desc,
      'Address' => "#{address} #{city}, #{zipcode}",
      'Status' => filter_status&.titleize
    }
  end
end
