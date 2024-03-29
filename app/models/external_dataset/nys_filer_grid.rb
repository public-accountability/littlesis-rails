# frozen_string_literal: true

module ExternalDataset
  class NYSFilerGrid < BaseGrid
    scope do
      ExternalDataset::NYSFiler.all
    end

    filter(:filer_name, :string, header: 'Name') do |value|
      where("to_tsvector(filer_name) @@ websearch_to_tsquery(?)", value)
    end

    filter(:zipcode, :string)

    column 'filer_id', order: false
    column('filer_name', order: false) do |record|
      format(record.filer_name) do
        link_to record.filer_name, nys_committee_path(id: record.filer_id), target: '_blank'
      end
    end
    column "compliance_type_desc", order: false
    column "filer_type_desc", order: false
    column "filer_status", order: false
    column "committee_type_desc", order: false
    column "office_desc", order: false
    column "district"
    column "county_desc"
    column "municipality_subdivision_desc"
    column "treasurer_first_name", order: false
    column "treasurer_middle_name", order: false
    column "treasurer_last_name", order: false
    column "address", order: false
    column "city"
    column "state"
    column "zipcode"
  end
end
