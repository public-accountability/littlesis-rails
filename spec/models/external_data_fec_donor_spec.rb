describe 'Matching Donors and Updating Relationships, Candidates, and Committees From FEC Data' do
  # Relationship ---> HasOneOrMany --> donor
  # Donor     --> Committee
  # Donor     --> Candidate (duplicate of committee relationship)

  # Committee ---> Candidate
  # ExternalData.fec_contribution

  # Mock of FEC::IndividualContribution
  MockFECIndividualContribution = Struct.new(:SUB_ID, :attributes)
  MockFECCommittee = Struct.new(:CMTE_ID, :FEC_YEAR, :attributes)

  def create_fec_contribution(attributes)
    ExternalData::Datasets::FECContribution
      .import_or_update MockFECIndividualContribution.new(attributes['SUB_ID'], attributes)
  end

  def create_fec_committee(attributes)
    ExternalData::Datasets::FECCommittee
      .import_or_update MockFECCommittee.new(attributes['CMTE_ID'], attributes['FEC_YEAR'], attributes)
  end

  # 3 committees: FOO_COMMITTEE, BAR_COMMITTEE, PAC_COMMITTEE
  # External Data
  let(:committees) do
    [
      create_fec_committee({
                             "CMTE_ID" => "FOO_COMMITTEE_ID",
                             "CMTE_NM" => "THE FOO COMMITTEE",
                             "TRES_NM" => "",
                             "CMTE_ST1" => "123 FOO ROAD",
                             "CMTE_ST2" => "",
                             "CMTE_CITY" => "FOO",
                             "CMTE_ST" => "NY",
                             "CMTE_ZIP" => "10001",
                             "CMTE_DSGN" => "P",
                             "CMTE_TP" => "house",
                             "CMTE_PTY_AFFILIATION" => "REP",
                             "CMTE_FILING_FREQ" => "Q",
                             "ORG_TP" => "",
                             "CONNECTED_ORG_NM" => nil,
                             "CAND_ID" => "H0CO07042",
                             "FEC_YEAR" => 2020,
                             "rowid" => 1
                           }),
      create_fec_committee({
                             "CMTE_ID" => "BAR_COMMITTEE_ID",
                             "CMTE_NM" => "THE FOO COMMITTEE",
                             "TRES_NM" => "",
                             "CMTE_ST1" => "123 BAR ROAD",
                             "CMTE_ST2" => "",
                             "CMTE_CITY" => "BAR",
                             "CMTE_ST" => "NY",
                             "CMTE_ZIP" => "10001",
                             "CMTE_DSGN" => "P",
                             "CMTE_TP" => "house",
                             "CMTE_PTY_AFFILIATION" => "DEM",
                             "CMTE_FILING_FREQ" => "Q",
                             "ORG_TP" => "",
                             "CONNECTED_ORG_NM" => nil,
                             "CAND_ID" => "H4NY07102",
                             "FEC_YEAR" => 2020,
                             "rowid" => 2
                           }),
      create_fec_committee({
                             "CMTE_ID" => "PAC_COMMITTEE_ID",
                             "CMTE_NM" => "NATIONAL ASSOCIATION FOR PACS",
                             "TRES_NM" => "WALTER, BARRY JR.",
                             "CMTE_ST1" => "123 PAC ROAD",
                             "CMTE_ST2" => "",
                             "CMTE_CITY" => "PAC",
                             "CMTE_ST" => "NY",
                             "CMTE_ZIP" => "10001",
                             "CMTE_DSGN" => "U",
                             "CMTE_TP" => "super_pac",
                             "CMTE_PTY_AFFILIATION" => "",
                             "CMTE_FILING_FREQ" => "A",
                             "ORG_TP" => "",
                             "CONNECTED_ORG_NM" => nil,
                             "CAND_ID" => nil,
                             "FEC_YEAR" => 2020,
                             "rowid" => 3
                           })
    ]
  end

  # 0 Donor --> foo committee ($1000)
  # 1 Donor --> foo committee ($2000)
  # 2 Donor --> bar committee ($3000)
  # 3 Donor --> pac committee ($4000)
  let(:contributions) do
    [
      create_fec_contribution({ "CMTE_ID" => "FOO_COMMITTEE_ID",
                                "TRANSACTION_TP" => "committee",
                                "NAME" => "DONOR, BIG",
                                "CITY" => "NEW YORK",
                                "STATE" => "NY",
                                "ZIP_CODE" => "10001",
                                "EMPLOYER" => "AMAZON",
                                "OCCUPATION" => "INVESTOR",
                                "TRANSACTION_DT" => "08302019",
                                "TRANSACTION_AMT" => "1000.0",
                                "SUB_ID" => 1001,
                                "FEC_YEAR" => 2020 }),
      create_fec_contribution({ "CMTE_ID" => "FOO_COMMITTEE_ID",
                                "TRANSACTION_TP" => "committee",
                                "NAME" => "DONOR, BIG",
                                "CITY" => "NEW YORK",
                                "STATE" => "NY",
                                "ZIP_CODE" => "10001",
                                "EMPLOYER" => "AMAZON",
                                "OCCUPATION" => "INVESTOR",
                                "TRANSACTION_DT" => "12012019",
                                "TRANSACTION_AMT" => "2000.0",
                                "SUB_ID" => 1002,
                                "FEC_YEAR" => 2020 }),
      create_fec_contribution({ "CMTE_ID" => "BAR_COMMITTEE_ID",
                                "TRANSACTION_TP" => "committee",
                                "NAME" => "DONOR, BIG",
                                "CITY" => "NEW YORK",
                                "STATE" => "NY",
                                "ZIP_CODE" => "10001",
                                "EMPLOYER" => "AMAZON",
                                "OCCUPATION" => "INVESTOR",
                                "TRANSACTION_DT" => "12012019",
                                "TRANSACTION_AMT" => "3000.0",
                                "SUB_ID" => 1003,
                                "FEC_YEAR" => 2020 }),
      create_fec_contribution({ "CMTE_ID" => "PAC_COMMITTEE_ID",
                                "TRANSACTION_TP" => "committee",
                                "NAME" => "DONOR, BIG",
                                "CITY" => "NEW YORK",
                                "STATE" => "NY",
                                "ZIP_CODE" => "10001",
                                "EMPLOYER" => "AMAZON",
                                "OCCUPATION" => "INVESTOR",
                                "TRANSACTION_DT" => "12012019",
                                "TRANSACTION_AMT" => "4000.0",
                                "SUB_ID" => 1004,
                                "FEC_YEAR" => 2020 })
    ]
  end

  # ExternalRelationship.fec_contribution
  # let!(:contributions_external_relationships) do
  #   contributions.map(&:external_relationship)
  # end

  # # ExternalData.fec_donor
  # let(:fec_donor) do
  # end

  # # ExternalEntity.fec_donor
  # let(:donor_external_entity) do
  #   donor.external_entity
  # end

  # # ExternalData.fec_committee
  let(:foo_fec_committee) do
  end

  # let(:bar_fec_committee) do
  # end

  # let(:pac_fec_committee) do
  # end

  # ExternalData.fec_candidate
  # let(:foo_fec_candidate) do
  # end

  # let(:bar_fec_candidate) do
  # end

  let(:entity_donor) do
    create(:entity_person)
  end

  let(:entity_foo_committee) do
    create(:entity_org)
  end

  let(:entity_foo_candidate) do
    create(:entity_person)
  end

  # let(:entity_bar_committee)
  # let(:entity_pac_committee)

  before do
    committees
    contributions
    ExternalData::CreateFECDonorsService.run
  end

  specify 'FEC Donors, and External relationships are created after importing' do
    expect(ExternalData.fec_committee.count).to eq 3
    expect(ExternalData.fec_contribution.count).to eq 4
    expect(ExternalRelationship.fec_contribution.count).to eq 4
    expect(ExternalEntity.fec_committee.count).to eq 3
    expect(ExternalData.fec_donor.count).to eq 1
    expect(ExternalData.fec_donor.last.wrapper.sub_ids.to_set).to eq [1001, 1002, 1003, 1004].to_set
  end

  # This is this "LittleSis interpretation" of FEC's data model.
  # Using ExternalData, ExternalEntity, and ExternalRelationships, LittleSis tries to maintain it's own interpretation of FEC's data
  #   - Donations between the same donor and recipient are groupped together into a single relationship
  #   - When the recipient committee is connected to a candidate, a second relationship is maintained between the donor and the candidate directly
  specify 'Matching Donations and Modifying LittleSis Relationships ' do
    expect(Relationship.exists?(entity: entity_donor, related: entity_foo_committee)).to be false
    expect(contributions[0].external_relationship.matched?).to be false
    expect(Relationship.exists?(entity: entity_donor, related: entity_foo_candidate)).to be false

    expect { committees.first.external_entity.automatch_or_create }.to change(Entity, :count).by(1)

    expect { ExternalRelationship::FECContributionAutomatchService.run }
      .to change { contributions[0].external_relationship.reload.entity2_matched? }.from(false).to(true)

    # expect(contributions[0].external_relationship.matched?).to be_false

    # contributions[0].external_relationship.match_entity1_with entity_donor

    # expect(contributions[0].external_relationship.matched?).to be_true
    # expect(Relationship.exist?(entity: entity_donor, related: foo_fec_committee)).to be_true
    # expect(Relationship.find_by(entity: entity_donor, related: foo_fec_candidate).amount).to eq 100

    # contributions[1].external_relationship.match_entity1_with entity_donor

    # expect(Relationship.where(entity: entity_donor, related: foo_fec_committee).count).to eq 1
    # expect(Relationship.find_by(entity: entity_donor, related: foo_fec_committee).amount).to eq 200
    # expect(Relationship.find_by(entity: entity_donor, related: foo_fec_candidate).amount).to eq 200

    # expect(Relationship.exist?(entity: entity_donor, related: pac_committee)).to be_false

    # contributions[2].external_relationship.match_entity1_with entity_donor
  end
end
