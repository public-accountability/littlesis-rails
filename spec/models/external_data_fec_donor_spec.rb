# These tests are for LittleSis's interpretation of FEC's bulk data.
# Using ExternalData, ExternalEntity, and ExternalRelationships, LittleSis tries to fit FEC's data
# into a set of relationships that makes sense for LittleSis.
#   - Donations between the same donor and recipient are groupped together into a single relationship
#   - When the recipient committee is connected to a candidate, a second relationship is maintained between the donor and the candidate directly
# If one donor have given to a single candidate through two committees (i.e. two different campaigns) the following models in
# the LittleSis database are all involved:
# 2 ExternalData/ExternalRelationship.fec_contribution
# 2 ExternalData/ExternalEntity.fec_committee
# 1 ExternalData/ExternalEntity.fec_candidate
# 1 ExternalData/ExternalEntity.fec_donor
# 3 ExternalLinks (2 fec_comittee, 1 fec_candidate)
# 4 Entities: 2 committees, 1 candidate, 1 donor
# 3 Relationships: donor->committee, donor->committee, donor->candidate
describe 'Matching Donors and Updating Relationships, Candidates, and Committees From FEC Data' do
  MockFECIndividualContribution = Struct.new(:SUB_ID, :attributes)
  MockFECCommittee = Struct.new(:CMTE_ID, :FEC_YEAR, :attributes)
  MockFECCandidate = Struct.new(:CAND_ID, :attributes)

  def create_fec_contribution(attributes)
    ExternalData::Datasets::FECContribution
      .import_or_update MockFECIndividualContribution.new(attributes['SUB_ID'], attributes)
  end

  def create_fec_committee(attributes)
    ExternalData::Datasets::FECCommittee
      .import_or_update MockFECCommittee.new(attributes['CMTE_ID'], attributes['FEC_YEAR'], attributes)
  end

  def create_fec_candidate(attributes)
    ExternalData::Datasets::FECCandidate
      .import_or_update MockFECCandidate.new(attributes['CAND_ID'], attributes)
  end

  # 3 committees: FOO_COMMITTEE, BAR_COMMITTEE, PAC_COMMITTEE
  # [<ExternalData>]
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
                             "CMTE_NM" => "THE BAR COMMITTEE",
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
  # [<ExternalData>]
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

  # [<ExternalData>]
  let(:candidates) do
    [
      create_fec_candidate({ "CAND_ID" => "H0CO07042",
                             "CAND_NAME" => "FOO, CANDIDATE",
                             "CAND_PTY_AFFILIATION" => "REP",
                             "CAND_ELECTION_YR" => 2010,
                             "CAND_OFFICE_ST" => "CO",
                             "CAND_OFFICE" => "H",
                             "CAND_OFFICE_DISTRICT" => "07",
                             "CAND_ICI" => "C",
                             "CAND_STATUS" => "N",
                             "CAND_PCC" => "FOO_COMMITTEE_ID",
                             "CAND_ST1" => "123 Foo Street",
                             "CAND_ST2" => "",
                             "CAND_CITY" => "BENNETT",
                             "CAND_ST" => "CO",
                             "CAND_ZIP" => "80102",
                             "FEC_YEAR" => 2018 }),
      create_fec_candidate({ "CAND_ID" => "H4NY07102",
                             "CAND_NAME" => "BAR, CANDIDATE",
                             "CAND_PTY_AFFILIATION" => "DEM",
                             "CAND_ELECTION_YR" => 2018,
                             "CAND_OFFICE_ST" => "NY",
                             "CAND_OFFICE" => "H",
                             "CAND_OFFICE_DISTRICT" => "07",
                             "CAND_ICI" => "C",
                             "CAND_STATUS" => "N",
                             "CAND_PCC" => "BAR_COMMITTEE_ID",
                             "CAND_ST1" => "1 Bar Street",
                             "CAND_ST2" => "",
                             "CAND_CITY" => "NEW YORK",
                             "CAND_ST" => "NY",
                             "CAND_ZIP" => "10002",
                             "FEC_YEAR" => 2018 })
    ]
  end

  let(:entity_donor) do
    create(:entity_person)
  end

  let(:entity_foo_candidate) do
    create(:entity_person).tap do |entity|
      entity.external_links.create!(link_type: :fec_candidate, link_id: 'H0CO07042')
    end
  end

  let(:entity_bar_candidate) do
    create(:entity_person)
  end

  before do
    entity_donor
    entity_foo_candidate
    committees
    candidates
    contributions
    ExternalData.services.create_fec_donors
  end

  specify 'FEC Donors, and External relationships are created after importing' do
    expect(ExternalData.fec_committee.count).to eq 3
    expect(ExternalData.fec_contribution.count).to eq 4
    expect(ExternalRelationship.fec_contribution.count).to eq 4
    expect(ExternalEntity.fec_committee.count).to eq 3
    expect(ExternalEntity.fec_candidate.count).to eq 2
    expect(ExternalData.fec_donor.count).to eq 1
    expect(ExternalData.fec_donor.last.wrapper.sub_ids.to_set).to eq [1001, 1002, 1003, 1004].to_set
  end

  # After all external data has been match the following LittleSis relationships should exist
  #   - Relationship between Donor and Foo Committee (aggregate of 2 two contributions)
  #   - Relationship between Donor and Bar Committee
  #   - Relationship between Donor and Foo Candidate
  #   - Relationship between Donor and Bar Candidate
  #   - Relationship between Donor and PAC Committee
  specify 'Matching Donations and Modifying LittleSis Relationships ' do
    expect(committees.first.external_entity.matched?).to be true # see ExternalEntity::Datasets::FECCommittee.automatch_or_create
    expect(committees.second.external_entity.matched?).to be true
    expect(candidates.first.external_entity.matched?).to be true
    expect(candidates.second.external_entity.matched?).to be false

    contributions.each { |c| expect(c.external_relationship.entity2_matched?).to be(false) }
    ExternalData.services.automatch_fec_contributions
    contributions.each(&:reload)
    contributions.each { |c| expect(c.external_relationship.entity2_matched?).to be(true) }
    expect(contributions[0].external_relationship.entity2_matched?).to be true
    expect(contributions[1].external_relationship.entity2_matched?).to be true

    # Matching contribution[0]
    expect(contributions[0].external_relationship.matched?).to be false
    expect(Relationship.exists?(entity: entity_donor, related: entity_foo_candidate)).to be false
    contributions[0].external_relationship.match_entity1_with(entity_donor)
    expect(contributions[0].external_relationship.matched?).to be true
    expect(Relationship.exists?(entity: entity_donor, related: entity_foo_candidate)).to be true
    expect(contributions[0].external_relationship.entity1).to eq entity_donor
    expect(contributions[0].external_relationship.relationship.amount).to eq 1_000
    expect(contributions[0].external_relationship.relationship.entity).to eq entity_donor

    # Matching contribution[1]
    expect(contributions[1].external_relationship.matched?).to be false
    contributions[1].external_relationship.match_entity1_with(entity_donor)
    expect(contributions[1].external_relationship.matched?).to be true
    expect(contributions[1].external_relationship.relationship).to eq contributions[0].external_relationship.relationship
    expect(contributions[1].external_relationship.relationship.amount).to eq 3_000

    # Matching contribution[2] Bar Committee
    expect(Relationship.exists?(entity: entity_donor, related: committees.second.external_entity.entity)).to be false
    expect { contributions[2].external_relationship.match_entity1_with(entity_donor) }
      .to change { contributions[2].external_relationship.matched? }.from(false).to(true)
    expect(Relationship.exists?(entity: entity_donor, related: committees.second.external_entity.entity)).to be true

    # Matching contribution[3] PAC Committee
    expect { contributions[3].external_relationship.match_entity1_with(entity_donor) }
      .to change { contributions[3].external_relationship.matched? }.from(false).to(true)

    # Matching candidate[1] Bar Candidate
    expect(candidates.second.external_entity.matched?).to be false
    expect(Relationship.exists?(entity: entity_donor, related: entity_bar_candidate)).to be false
    candidates.second.external_entity.match_with entity_bar_candidate
    expect(Relationship.exists?(entity: entity_donor, related: entity_bar_candidate)).to be false
    ExternalData.services.synchronize_fec_candidate_relationships
    expect(Relationship.exists?(entity: entity_donor, related: entity_bar_candidate)).to be true
  end
end
