FactoryBot.define do
  factory :external_data do
    dataset { "" }
    dataset_id { "" }
    data { "" }
  end

  factory :external_data_nycc_borelli, class: 'ExternalData' do
    dataset { "nycc" }
    dataset_id { Faker::Number.unique.number(digits: 4).to_s }
    data do
      {
        "District" => "51",
        "PersonId" => "7264",
        "Party" => "Republican",
        "FullName" => "Joseph C. Borelli"
      }
    end
  end

  factory :external_data_nycc_constantinides, class: 'ExternalData' do
    dataset { "nycc" }
    dataset_id { Faker::Number.unique.number(digits: 4).to_s }
    data do
      {
        "District" => "22",
        "PersonId" => "7627",
        "CouncilDistrict" => "NYCC51",
        "Party" => "Democrat",
        "FullName" => "Costa G. Constantinides"
      }
    end
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
        "advisor_name" => "Iapd Advisor",
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

  factory :external_data_nys_filer, class: 'ExternalData' do
    dataset { "nys_filer" }
    dataset_id { 'A123456' }
    data do
      { 'filer_id' => 'A123456',
        'name' => 'Foo Bar',
        'filer_type' => 'CANDIDATE',
        'status' => 'INACTIVE',
        'committee_type' => '',
        'office' => '42',
        'district' => '1',
        'treas_first_name' => 'Foo',
        'treas_last_name' => 'Bar',
        'address' => 'PO Box 1',
        'city' => 'New York',
        'state' => 'NY',
        'zip' => '10001' }
    end
  end

  # transaction_code = A
  factory :external_data_nys_disclosure, class: 'ExternalData' do
    dataset { 'nys_disclosure' }
    dataset_id { "A01182-F-A-2006-7452" }
    data do
      {
        "FILER_ID" => "A01182",
        "FREPORT_ID" => "F",
        "TRANSACTION_CODE" => "A",
        "E_YEAR" => "2006",
        "T3_TRID" => "7452",
        "DATE1_10" => "11/06/2006",
        "DATE2_12" => "",
        "CONTRIB_CODE_20" => "IND",
        "CONTRIB_TYPE_CODE_25" => "",
        "CORP_30" => "",
        "FIRST_NAME_40" => "FRANK",
        "MID_INIT_42" => "",
        "LAST_NAME_44" => "UNKNOWN",
        "ADDR_1_50" => "123 MAIN ST",
        "CITY_52" => "BUFFALO",
        "STATE_54" => "NY",
        "ZIP_56" => "14203",
        "CHECK_NO_60" => "176",
        "CHECK_DATE_62" => "",
        "AMOUNT_70" => "500",
        "AMOUNT2_72" => "",
        "DESCRIPTION_80" => "",
        "OTHER_RECPT_CODE_90" => "",
        "PURPOSE_CODE1_100" => "",
        "PURPOSE_CODE2_1" => "",
        "EXPLANATION_110" => "",
        "XFER_TYPE_120" => "",
        "CHKBOX_130" => "",
        "CREREC_UID" => "KB",
        "CREREC_DATE" => '11/27/2006 15:03:44'
      }
    end
  end

  factory :external_data_nys_disclosure_transaction_code_f, class: 'ExternalData' do
    dataset { 'nys_disclosure' }
    dataset_id { "A00076-J-F-2003-1868" }
    data do
      {
        "FILER_ID" => "A00076",
        "FREPORT_ID" => "J",
        "TRANSACTION_CODE" => "F",
        "E_YEAR" => "2003",
        "T3_TRID" => "1868",
        "DATE1_10" => "07/10/2002",
        "DATE2_12" => "",
        "CONTRIB_CODE_20" => "",
        "CONTRIB_TYPE_CODE_25" => "",
        "CORP_30" => "FOO BAR",
        "FIRST_NAME_40" => "",
        "MID_INIT_42" => "",
        "LAST_NAME_44" => "",
        "ADDR_1_50" => "456 MAIN ST",
        "CITY_52" => "GREENWICH",
        "STATE_54" => "CT",
        "ZIP_56" => "06830",
        "CHECK_NO_60" => "1008",
        "CHECK_DATE_62" => "",
        "AMOUNT_70" => "1800",
        "AMOUNT2_72" => "",
        "DESCRIPTION_80" => "",
        "OTHER_RECPT_CODE_90" => "",
        "PURPOSE_CODE1_100" => "WAGES",
        "PURPOSE_CODE2_1" => "",
        "EXPLANATION_110" => "JULY SALARY",
        "XFER_TYPE_120" => "",
        "CHKBOX_130" => "",
        "CREREC_UID" => "HH",
        "CREREC_DATE" => '12/19/2002 13:11:51'
      }
    end
  end
end
