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
end
