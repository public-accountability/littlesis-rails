FactoryBot.define do
  factory :external_dataset_fec_contribution, class: 'ExternalDataset::FECContribution' do
    sub_id { Faker::Number.number(digits: 12) }
    cmte_id { "C00431445" }
    amndt_ind { "A" }
    rpt_tp { "M9" }
    transaction_pgi { "P" }
    image_num { Faker::Number.number(digits: 10).to_s }
    transaction_tp { "15" }
    entity_tp { "IND" }
    name { "#{Faker::Name.last_name.upcase}, #{Faker::Name.first_name.upcase}" }
    city { Faker::Address.city }
    state { Faker::Address.state }
    zip_code { nil }
    employer { Faker::Company.name }
    occupation { Faker::Job.title }
    transaction_dt {  "08272012" }
    transaction_amt { 2500 }
    other_id { nil }
    tran_id { "C19950573" }
    file_num { Faker::Number.number(digits: 6) }
    memo_cd { nil }
    memo_text { nil }
    fec_year { 2012 }
  end

  factory :external_dataset_fec_committee, class: 'ExternalDataset::FECCommittee' do
    cmte_id { "C00431445" }
    cmte_nm { "OBAMA FOR AMERICA" }
    tres_nm { "NESBITT, MARTIN H" }
    cmte_st1 { "PO BOX 8102" }
    cmte_city { "CHICAGO" }
    cmte_st { "IL" }
    cmte_zip { "60680" }
    cmte_dsgn { "P" }
    cmte_tp { "P" }
    cmte_pty_affiliation { "DEM" }
    cmte_filing_freq { "M" }
    connected_org_nm { "OBAMA VICTORY FUND 2012" }
    cand_id { "P80003338" }
    fec_year { 2012 }
  end
end
