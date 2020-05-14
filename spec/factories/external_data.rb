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

  factory :external_data_iapd_owner, class: 'ExternalData' do
    dataset { "iapd_owners" }
    dataset_id { "1000018" }
    data do
      JSON.parse <<~JSON
        [
          {
            "filing_id": 1077811,
            "scha_3": "Y",
            "schedule": "A",
            "name": "BATES, DOUGLAS, K",
            "owner_type": "I",
            "entity_in_which": "",
            "title_or_status": "ADVISORY BOARD",
            "acquired": "09/2001",
            "ownership_code": "NA",
            "control_person": "Y",
            "public_reporting": "N",
            "owner_id": "1000018",
            "filename": "IA_Schedule_A_B_20170101_20170331.csv",
            "owner_key": "1000018",
            "advisor_crd_number": 116865
          },
          {
            "filing_id": 1077811,
            "scha_3": "",
            "schedule": "B",
            "name": "BATES, DOUGLAS, K",
            "owner_type": "I",
            "entity_in_which": "SOCKEYE TRADING COMPANY, INC.",
            "title_or_status": "MEMBER",
            "acquired": "01/2009",
            "ownership_code": "C",
            "control_person": "Y",
            "public_reporting": "N",
            "owner_id": "1000018",
            "filename": "IA_Schedule_A_B_20170101_20170331.csv",
            "owner_key": "1000018",
            "advisor_crd_number": 116865
          },
          {
            "filing_id": 1131348,
            "scha_3": "",
            "schedule": "B",
            "name": "BATES, DOUGLAS, K",
            "owner_type": "I",
            "entity_in_which": "SOCKEYE TRADING COMPANY, INC.",
            "title_or_status": "MEMBER",
            "acquired": "01/2009",
            "ownership_code": "C",
            "control_person": "Y",
            "public_reporting": "N",
            "owner_id": "1000018",
            "filename": "IA_Schedule_A_B_20170701_20170930.csv",
            "owner_key": "1000018",
            "advisor_crd_number": 116865
          },
          {
            "filing_id": 1131348,
            "scha_3": "Y",
            "schedule": "A",
            "name": "BATES, DOUGLAS, K",
            "owner_type": "I",
            "entity_in_which": "",
            "title_or_status": "ADVISORY BOARD",
            "acquired": "09/2001",
            "ownership_code": "NA",
            "control_person": "Y",
            "public_reporting": "N",
            "owner_id": "1000018",
            "filename": "IA_Schedule_A_B_20170701_20170930.csv",
            "owner_key": "1000018",
            "advisor_crd_number": 116865
          },
          {
            "filing_id": 1174430,
            "scha_3": "Y",
            "schedule": "A",
            "name": "BATES, DOUGLAS, K",
            "owner_type": "I",
            "entity_in_which": "",
            "title_or_status": "ADVISORY BOARD",
            "acquired": "09/2001",
            "ownership_code": "NA",
            "control_person": "Y",
            "public_reporting": "N",
            "owner_id": "1000018",
            "filename": "IA_Schedule_A_B_20180101_20180331.csv",
            "owner_key": "1000018",
            "advisor_crd_number": 116865
          }
        ]
      JSON
    end
  end
end
