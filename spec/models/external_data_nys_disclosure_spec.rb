describe 'NYS Disclosure External Data' do
  let(:filer_id) { "A00266" }

  let!(:external_data_nys_disclosure) do
    ExternalData.create!(dataset: "nys_disclosure",
                         dataset_id: "A00266-K-A-2005-3255",
                         data: { "FILER_ID" => filer_id,
                                 "FREPORT_ID" => "K",
                                 "TRANSACTION_CODE" => "A",
                                 "E_YEAR" => "2005",
                                 "T3_TRID" => "3255",
                                 "DATE1_10" => "06/09/2005",
                                 "DATE2_12" => "",
                                 "CONTRIB_CODE_20" => "IND",
                                 "CONTRIB_TYPE_CODE_25" => "",
                                 "CORP_30" => "",
                                 "FIRST_NAME_40" => "JOSEPH",
                                 "MID_INIT_42" => "",
                                 "LAST_NAME_44" => "P",
                                 "ADDR_1_50" => "123 MAIN ST",
                                 "CITY_52" => "WHITE PLAINS",
                                 "STATE_54" => "NY",
                                 "ZIP_56" => "10601",
                                 "CHECK_NO_60" => "584",
                                 "CHECK_DATE_62" => "",
                                 "AMOUNT_70" => "300",
                                 "AMOUNT2_72" => "",
                                 "DESCRIPTION_80" => "",
                                 "OTHER_RECPT_CODE_90" => "",
                                 "PURPOSE_CODE1_100" => "",
                                 "PURPOSE_CODE2_1" => "",
                                 "EXPLANATION_110" => "",
                                 "XFER_TYPE_120" => "",
                                 "CHKBOX_130" => "",
                                 "CREREC_UID" => "CF",
                                 "CREREC_DATE" => "07/15/2005 11:52:52" })
  end

  let!(:external_data_nys_filer) do
    ExternalData.create!(dataset: 'nys_filer',
                         dataset_id: filer_id,
                         data: { "filer_id" => filer_id,
                                 "name" => "FRIENDS OF VITO LOPEZ",
                                 "filer_type" => "COMMITTEE",
                                 "status" => "ACTIVE",
                                 "committee_type" => "1",
                                 "office" => "12",
                                 "district" => "53",
                                 "treas_first_name" => "CHRISTIANA",
                                 "treas_last_name" => "L",
                                 "address" => "123 Bay Street",
                                 "city" => "BAYSIDE",
                                 "state" => "NY",
                                 "zip" => "11360" })
  end

  let(:external_relationship_nys_disclosure) do
    create(:external_relationship,
           dataset: 'nys_disclosure',
           external_data: external_data_nys_disclosure,
           category_id: Relationship::POSITION_CATEGORY)
  end

  let(:external_entity_nys_filer) do
    create(:external_entity,
           dataset: 'nys_filer',
           external_data: external_data_nys_filer)
  end

  specify 'ExternalData: #external_relationship? and #external_entity?' do
    expect(external_data_nys_disclosure.external_relationship?).to be true
    expect(external_data_nys_disclosure.external_entity?).to be false
    expect(external_data_nys_filer.external_relationship?).to be false
    expect(external_data_nys_filer.external_entity?).to be true
  end

  describe 'nys disclosure wrapper' do
    subject { external_data_nys_disclosure.wrapper }

    assert_method_call :filer_id, "A00266"
    assert_method_call :amount_str, "$300"
    assert_method_call :donor_primary_ext, 'Person'
    assert_method_call :transaction_code, 'Contribution (A)'
    assert_method_call :date, '2005-06-09'
    assert_method_call :filer_name, 'Friends Of Vito Lopez'
    assert_method_call :recipient_primary_ext, 'Person'
  end

  describe 'nys filer wrapper' do
    subject { external_data_nys_filer.wrapper }

    assert_method_call :individual_campaign_committee?, true
    assert_method_call :office_description, 'Member of Assembly'
    assert_method_call :committee_type_description, 'Individual'
  end

  describe 'NysFiler.find_by_filer_id' do
    specify do
      expect(ExternalData::Datasets::NYSFiler.find_by_filer_id(filer_id))
        .to eq external_data_nys_filer
    end

    specify do
      expect(ExternalData::Datasets::NYSFiler.find_by_filer_id(filer_id).filer_name)
        .to eq 'FRIENDS OF VITO LOPEZ'
    end
  end

  describe 'External Relationship: NYS Filer' do
    specify 'potential_matches_entity1' do
      expect(EntityMatcher).to receive(:find_matches_for_person).with('Joseph P').once
      external_relationship_nys_disclosure.potential_matches_entity1
    end
  end
end
