FactoryBot.define do
  factory :external_dataset_iapd_owner, class: IapdDatum do
    type { 'IapdDatum' }
    primary_ext { :person }
    dataset_key { '7007566' }
    row_data do
      { 'owner_key' => '7007566',
        'name' => 'SELBER, BLAIR C',
        'class' => 'IapdDatum::IapdOwner',
        'data' => [{ 'filing_id' => 1_250_755,
                     'scha_3' => 'Y',
                     'schedule' => 'A',
                     'name' => 'SELBER, BLAIR C',
                     'owner_type' => 'I',
                     'entity_in_which' => '',
                     'title_or_status' => 'DIRECTOR',
                     'acquired' => '08/2018',
                     'ownership_code' => 'NA',
                     'control_person' => 'Y',
                     'public_reporting' => '',
                     'owner_id' => '7007566',
                     'filename' => 'IA_Schedule_A_B_20181001_20181231.csv',
                     'owner_key' => '7007566',
                     'advisor_crd_number' => 19_585 }] }
    end
  end

  factory :external_dataset_iapd_owner_without_crd, class: IapdDatum do
    type { 'IapdDatum' }
    primary_ext { :person }
    dataset_key { '12-123456' }
    row_data do
      { 'owner_key' => '12-123456',
        'name' => 'SELBER, BLAIR C',
        'class' => 'IapdDatum::IapdOwner',
        'data' => [{ 'filing_id' => 1_250_755,
                     'scha_3' => 'Y',
                     'schedule' => 'A',
                     'name' => 'SELBER, BLAIR C',
                     'owner_type' => 'I',
                     'entity_in_which' => '',
                     'title_or_status' => 'DIRECTOR',
                     'acquired' => '08/2018',
                     'ownership_code' => 'NA',
                     'control_person' => 'Y',
                     'public_reporting' => '',
                     'owner_id' => '7007566',
                     'filename' => 'IA_Schedule_A_B_20181001_20181231.csv',
                     'owner_key' => '7007566',
                     'advisor_crd_number' => 19_585 }] }
    end
  end

  factory :external_dataset_iapd_advisor, class: IapdDatum do
    type { 'IapdDatum' }
    primary_ext { :org }
    dataset_key { Faker::Number.unique.number }
    row_data do
      { 'crd_number' => 126_188,
        'name' => 'TIMOTHY J. ELLIS, INC.',
        'class' => 'IapdDatum::IapdAdvisor',
        'data' => [{ 'name' => 'TIMOTHY J. ELLIS, INC.',
                     'dba_name' => 'TIMOTHY J. ELLIS, INC.',
                     'crd_number' => '126188',
                     'sec_file_number' => '801-80511',
                     'assets_under_management' => 74_864_178,
                     'total_number_of_accounts' => 257,
                     'filing_id' => 1_243_455,
                     'date_submitted' => '10/01/2018 01:28:59 PM',
                     'filename' => 'IA_ADV_Base_A_20181001_20181231.csv' },
                   { 'name' => 'TIMOTHY J. ELLIS, INC.',
                     'dba_name' => 'TIMOTHY J. ELLIS, INC.',
                     'crd_number' => '126188',
                     'sec_file_number' => '801-80511',
                     'assets_under_management' => 74_864_178,
                     'total_number_of_accounts' => 257,
                     'filing_id' => 1_234_105,
                     'date_submitted' => '09/14/2018 12:29:20 PM',
                     'filename' => 'IA_ADV_Base_A_20180701_20180930.csv' },
                   { 'name' => 'TIMOTHY J. ELLIS, INC.',
                     'dba_name' => 'TIMOTHY J. ELLIS, INC.',
                     'crd_number' => '126188',
                     'sec_file_number' => '801-80511',
                     'assets_under_management' => 74_864_178,
                     'total_number_of_accounts' => 257,
                     'filing_id' => 1_172_226,
                     'date_submitted' => '02/15/2018 02:28:47 PM',
                     'filename' => 'IA_ADV_Base_A_20180101_20180331.csv' },
                   { 'name' => 'TIMOTHY J. ELLIS, INC.',
                     'dba_name' => 'TIMOTHY J. ELLIS, INC.',
                     'crd_number' => '126188',
                     'sec_file_number' => '801-80511',
                     'assets_under_management' => 66_331_960,
                     'total_number_of_accounts' => 124,
                     'filing_id' => 1_071_005,
                     'date_submitted' => '02/10/2017 12:09:45 PM',
                     'filename' => 'IA_ADV_Base_A_20170101_20170331.csv' }] }
    end
  end
end
