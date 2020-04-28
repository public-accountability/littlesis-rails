FactoryBot.define do
  factory :external_data do
    dataset { "" }
    dataset_id { "" }
    data { "" }
  end

  factory :external_data_iapd_advisor, class: 'ExternalData' do
    dataset { "iapd_advisors" }
    dataset_id { '305893' }
    data do
      [{ 'name' => 'SWEETWATER INVESTMENTS LLC',
         'dba_name' => 'SWEETWATER INVESTMENTS LLC',
         'crd_number' => '305893',
         'sec_file_number' => '801-117821',
         'assets_under_management' => 0,
         'total_number_of_accounts' => 0,
         'filing_id' => 1_346_384,
         'date_submitted' => '11/18/2019 08:21:42 PM',
         'filename' => 'IA_ADV_Base_A_20191001_20191231.csv' }]
    end
  end

  factory :external_data_iapd_advisor2, class: 'ExternalData' do
    dataset { "iapd_advisors" }
    dataset_id { "126188" }
    data do
      [{ "name" => "TIMOTHY J. ELLIS, INC.",
         "dba_name" => "TIMOTHY J. ELLIS, INC.",
         "crd_number" => "126188",
         "sec_file_number" => "801-80511",
         "assets_under_management" => 74864178,
         "total_number_of_accounts" => 257,
         "filing_id" => 1243455,
         "date_submitted" => "10/01/2018 01:28:59 PM",
         "filename" => "IA_ADV_Base_A_20181001_20181231.csv" },
       { "name" => "TIMOTHY J. ELLIS, INC.",
         "dba_name" => "TIMOTHY J. ELLIS, INC.",
         "crd_number" => "126188",
         "sec_file_number" => "801-80511",
         "assets_under_management" => 72450685,
         "total_number_of_accounts" => 260,
         "filing_id" => 1274716,
         "date_submitted" => "02/26/2019 04:05:44 PM",
         "filename" => "IA_ADV_Base_A_20190101_20190331.csv" }]
    end
  end
end
