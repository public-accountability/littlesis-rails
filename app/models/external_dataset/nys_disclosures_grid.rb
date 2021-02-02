# frozen_string_literal: true

module ExternalDataset
  class NYSDisclosuresGrid < BaseGrid
    scope do
      ExternalDataset::NYSDisclosures.where(fec_year: [2020, 2022])
    end

    column(:filer_id)
    column(:transaction_code)
    column(:e_year)
    column(:date1_10)
    column(:corp_30)
    column("first_name_40")
    column("mid_init_42")
    column("last_name_44")
    column("addr_1_50")
    column("city_52")
    column("state_54")
    column("zip_56")
    column("amount_70")
    column("description_80")
  end
end
