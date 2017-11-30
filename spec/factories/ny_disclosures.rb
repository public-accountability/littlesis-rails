FactoryBot.define do
  factory :ny_disclosure, class: NyDisclosure do
    filer_id { SecureRandom.hex(2) }
    report_id "A"
    transaction_code 'A'
    e_year '2014'
    transaction_id '123'
    schedule_transaction_date '1999-01-14'
    amount1 { rand(5000) }
    sequence(:id)
  end

  factory :ny_disclosure_for_import_test, class: NyDisclosure do
    filer_id "A00076"
    report_id "J"
    transaction_id "2092"
    transaction_code 'A'
    e_year "2006"
    schedule_transaction_date '2005-07-13'
  end
end
