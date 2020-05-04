describe ExternalData, type: :model do
  it { is_expected.to have_db_column(:dataset).of_type(:integer) }
  it { is_expected.to have_db_column(:dataset_id).of_type(:string) }
  it { is_expected.to have_db_column(:data).of_type(:text) }

  describe ExternalData::IapdOwner do
    specify 'person owner' do
      owner = ExternalData::IapdOwner.new([
                                            { 'owner_type' => 'I' }
                                          ])
      expect(owner.send(:instance_variable_get, :@primary_ext)).to eq 'Person'
      expect(owner.person?).to be true
    end

    specify 'advisor_relationships' do
      owner = ExternalData::IapdOwner.new attributes_for(:external_data_iapd_owner)[:data]

      expect(owner.advisor_relationships).to eq([
                                                  { "filing_id" => 1174430,
                                                    "scha_3" => "Y",
                                                    "schedule" => "A",
                                                    "name" => "BATES, DOUGLAS, K",
                                                    "owner_type" => "I",
                                                    "entity_in_which" => "",
                                                    "title_or_status" => "ADVISORY BOARD",
                                                    "acquired" => "09/2001",
                                                    "ownership_code" => "NA",
                                                    "control_person" => "Y",
                                                    "public_reporting" => "N",
                                                    "owner_id" => "1000018",
                                                    "filename" => "IA_Schedule_A_B_20180101_20180331.csv",
                                                    "owner_key" => "1000018",
                                                    "advisor_crd_number" => 116865
                                                  }
                                                ])

    end
  end
end
