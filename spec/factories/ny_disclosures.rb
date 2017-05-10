FactoryGirl.define do
  factory :ny_disclosure, class: NyDisclosure do
    filer_id 'A1'
    report_id "A"
    transaction_code 'A'
    e_year '2014'
    transaction_id '123'
    schedule_transaction_date '1999-01-14'
  end

  factory :ny_disclosure_for_import_test, class: NyDisclosure do
    filer_id "A00076"
    report_id "A"
    transaction_id "3075"
    transaction_code 'E'
    e_year "1999"
    schedule_transaction_date '1999-01-14'
  end
end
