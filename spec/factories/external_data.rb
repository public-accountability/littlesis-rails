FactoryBot.define do
  factory :external_data do
    dataset { "" }
    dataset_id { "" }
    data { "" }
  end

  factory :external_data_iapd_advisor, class: 'ExternalData' do
    dataset { "iapd_advisors" }
    dataset_id { "100" }
    data do
      {
        "crd_number" => "100",
        "first_filename" => "IA_ADV_Base_A_20160101_20160331.csv",
        "latest_filename" => "IA_ADV_Base_A_20190701_20190930.csv",
        "latest_filing_id" => 1335833,
        "latest_aum" => 2397975077,
        "sec_file_numbers" => ["801-80511"],
        "latest_date_submitted" => "11/13/2019 05:12:22 PM",
        "names" => ["BOENNING & SCATTERGOOD, INC."],
        "filing_ids" => [970358, 1040954, 1055041, 1083314, 1124732, 1179395, 1225137, 1238427, 1304285, 1335833]
      }
    end
  end

  factory :external_data_schedule_a, class: 'ExternalData' do
    dataset { "iapd_schedule_a" }
    dataset_id { "1000018" }
    data do
      {
        "owner_key" => "01-0940455",
        "advisor_crd_number" => "175116",
        "records" => [{ "filing_id" => 1289264,
                        "schedule" => "A",
                        "scha_3" => "Y",
                        "name" => "CK PETROLEUM, LLC",
                        "owner_type" => "DE",
                        "title_or_status" => "MANAGER/MEMBER",
                        "acquired" => "May-12",
                        "ownership_code" => "D",
                        "control_person" => "Y",
                        "public_reporting" => "N",
                        "owner_id" => "01-0940455",
                        "filename" => "IA_Schedule_A_B_20190101_20190331.csv",
                        "iapd_year" => "2019" }],
        "filing_ids" => [1289264]
      }
    end
  end
end
