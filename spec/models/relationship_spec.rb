# frozen_string_literal: true

describe Relationship, type: :model do
  let(:person1) { create(:entity_person, :with_person_name) }
  let(:person2) { create(:entity_person, :with_person_name) }

  describe 'associations' do
    it { is_expected.to have_many(:links) }
    it { is_expected.to belong_to(:entity).optional }
    it { is_expected.to belong_to(:related).optional }
    it { is_expected.to have_one(:position) }
    it { is_expected.to have_one(:education) }
    it { is_expected.to have_one(:membership) }
    it { is_expected.to have_one(:family) }
    it { is_expected.to have_one(:trans) }
    it { is_expected.to have_one(:ownership) }
    it { is_expected.to belong_to(:category) }
    it { is_expected.to belong_to(:last_user).optional }
    it { is_expected.to have_many(:os_matches) }
    it { is_expected.to have_many(:os_donations) }
    it { is_expected.to have_many(:ny_matches) }
    it { is_expected.to have_many(:ny_disclosures) }

    it 'aliases trans as transaction' do
      expect(Trans).to eql Transaction
      expect(Transaction.new).to be_a Trans
      expect(Trans.new).to be_a Transaction
    end
  end

  describe 'adding references to entities' do
    let(:document_attrs) { attributes_for(:document) }
    let(:entity1) { create(:entity_person) }
    let(:entity2) { create(:entity_person) }
    let!(:relationship) { create(:generic_relationship, entity: entity1, related: entity2) }

    it 'adds document to entity' do
      expect { relationship.add_reference(document_attrs) }
        .to change { entity1.reload.references.count }.from(0).to(1)
      expect(entity1.references.last.document.url).to eq document_attrs[:url]
    end

    it 'adds document to related' do
      expect { relationship.add_reference(document_attrs) }
        .to change { entity2.reload.references.count }.from(0).to(1)
      expect(entity2.references.last.document.url).to eq document_attrs[:url]
    end
  end

  describe 'methods from concerns' do
    it 'has description_sentence' do
      expect(Relationship.new.respond_to?(:description_sentence)).to be true
    end

    it 'has find_similar' do
      expect(Relationship.new.respond_to?(:find_similar)).to be true
    end

    it 'has find_similar class method' do
      expect(Relationship.respond_to?(:find_similar)).to be true
    end
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:entity1_id) }
    it { is_expected.to validate_presence_of(:entity2_id) }
    it { is_expected.to validate_presence_of(:category_id) }
    it { is_expected.to validate_length_of(:start_date).is_at_most(10) }
    it { is_expected.to validate_length_of(:end_date).is_at_most(10) }
    it { is_expected.to validate_length_of(:description1).is_at_most(100) }
    it { is_expected.to validate_length_of(:description2).is_at_most(100) }

    describe 'Date Validation' do
      def rel(attr)
        r = build(:relationship, {category_id: 12, entity1_id: 123, entity2_id: 456}.merge(attr))
        allow(r).to receive(:entity).and_return(double('person double', :person? => true, :org? => false))
        allow(r).to receive(:related).and_return(double('person double', :person? => true, :org? => false))
        r
      end

      it 'accepts good dates' do
        expect(rel(start_date: '2000-00-00').valid?).to be true
        expect(rel(end_date: '2000-10-00').valid?).to be true
        expect(rel(end_date: '2017-01-20').valid?).to be true
        expect(rel(start_date: nil).valid?).to be true
      end

      it 'rejects bad dates' do
        expect(rel(start_date: '2000-13-00').valid?).to be false
        expect(rel(end_date: '2000-10').valid?).to be false
        expect(rel(end_date: '2017').valid?).to be false
        expect(rel(start_date: '').valid?).to be false
      end

      it 'rejects start dates that are after end dates' do
        expect(rel(start_date: '2019-01-01', end_date: '2018-12-31').valid?).to be false
      end
    end

    describe 'Relationship Validations' do
      it 'validates position relationship' do
        person = create(:entity_person)
        org = create(:entity_org)
        rel = Relationship.new(category_id: 1, entity: person, related: org)
        expect(rel.valid?).to eq true
      end

      it 'fails to validate bad HIERARCHY_CATEGORY relationship' do
        rel = Relationship.new(category_id: 11, entity: person1, related: person2)
        expect(rel.valid?).to eq false
        expect(rel.errors.full_messages[0]).to eql 'Category Hierarchy is not a valid category for Person to Person relationships'
      end
    end
  end

  describe 'category helpers' do
    specify do
      expect(build(:position_relationship).is_position?).to be true
      expect(build(:generic_relationship).is_position?).to be false
    end

    specify do
      expect(build(:education_relationship).is_education?).to be true
      expect(build(:generic_relationship).is_education?).to be false
    end

    specify do
      expect(build(:membership_relationship).is_membership?).to be true
      expect(build(:generic_relationship).is_membership?).to be false
    end

    specify do
      expect(build(:family_relationship).is_family?).to be true
      expect(build(:generic_relationship).is_family?).to be false
    end

    specify do
      expect(build(:donation_relationship).is_donation?).to be true
      expect(build(:generic_relationship).is_donation?).to be false
    end

    specify do
      expect(build(:transaction_relationship).is_transaction?).to be true
      expect(build(:generic_relationship).is_transaction?).to be false
    end

    specify do
      expect(build(:lobbying_relationship).is_lobbying?).to be true
      expect(build(:generic_relationship).is_lobbying?).to be false
    end

    specify do
      expect(build(:social_relationship).is_social?).to be true
      expect(build(:generic_relationship).is_social?).to be false
    end

    specify do
      expect(build(:professional_relationship).is_professional?).to be true
      expect(build(:generic_relationship).is_professional?).to be false
    end

    specify do
      expect(build(:ownership_relationship).is_ownership?).to be true
      expect(build(:generic_relationship).is_ownership?).to be false
    end

    specify do
      expect(build(:hierarchy_relationship).is_hierarchy?).to be true
      expect(build(:generic_relationship).is_hierarchy?).to be false
    end

    specify do
      expect(build(:position_relationship).is_generic?).to be false
      expect(build(:generic_relationship).is_generic?).to be true
    end
  end

  describe 'us_legislator?' do
    let(:bernie_house_relationship) do
      build(:membership_relationship,
            entity: build(:person, name: 'Bernie Sanders'),
            related: build(:us_house),
            membership: build(:bernie_house_membership))
    end

    let(:regular_person_relationship) do
      build(:membership_relationship,
            entity: build(:person),
            related: build(:org),
            membership: build(:membership))
    end

    example 'bernie sanders' do
      expect(bernie_house_relationship.us_legislator?).to be true
    end

    example 'regular person' do
      expect(regular_person_relationship.us_legislator?).to be false
    end

    example 'position relationship' do
      expect(build(:position_relationship,
                   entity: build(:person),
                   related: build(:us_senate)).us_legislator?).to be false
    end
  end

  describe 'touch: entity and related' do
    let(:elected) { create(:elected) }
    let(:org) { create(:entity_org) }

    before do
      elected
      org
    end

    it 'updates updated_at of entity after change' do
      rel = Relationship.create!(entity1_id: elected.id, entity2_id: org.id, category_id: 12, description1: 'relationship')
      elected.update_columns(updated_at: 1.week.ago)
      expect { rel.update(description1: 'new title') }.to change { Entity.find(elected.id).updated_at }
    end

    it 'updates updated_at of related after change' do
      rel = Relationship.create(entity1_id: elected.id, entity2_id: org.id, category_id: 12, description1: 'relationship')
      org.update_columns(updated_at: 1.week.ago)
      expect { rel.update(description1: 'new title') }.to change { Entity.find(org.id).updated_at }
    end
  end

  describe '#update_entity_timestatmps' do
    let(:user_1) { create(:user) }
    let(:user_2) { create(:user) }
    let(:user_3) { create(:user) }
    let(:e1) { create(:entity_person, last_user_id: user_1.id) }
    let(:e2) { create(:entity_person, last_user_id: user_1.id) }

    before { e1; e2; user_1; user_2; user_3; }

    it 'updates entity timestamp' do
      rel = Relationship.create!(category_id: 12, entity: e1, related: e2, last_user_id: user_2.id)
      e1.update_columns(updated_at: 1.day.ago)
      expect { rel.update_entity_timestamps }.to change { Entity.find(e1.id).updated_at }
    end

    it 'changes entity last_user_id' do
      rel = Relationship.create!(category_id: 12, entity: e1, related: e2, last_user_id: user_2.id)
      expect(Entity.find(e1.id).last_user_id).to eq user_2.id
      rel.update(description1: 'this is a description', last_user_id: user_3.id)
      expect(Entity.find(e1.id).last_user_id).to eq user_3.id
    end

    it 'changes related last_user_id' do
      rel = Relationship.create!(category_id: 12, entity: e1, related: e2, last_user_id: user_2.id)
      rel.update(description1: 'this is a description')
      expect(Entity.find(e2.id).last_user_id).to eq user_2.id
    end
  end

  describe 'category functions' do
    describe 'create_category' do
      it 'creates associated category model' do
        rel = build(:position_relationship)
        expect(Position).to receive(:create).with(relationship: rel).once
        rel.send(:create_category)
      end

      it 'creates model Position after relationship is created' do
        expect { Relationship.create!(category_id: 1, entity: person1, related: create(:entity_org)) }
          .to change(Position, :count).by(1)
      end

      it 'create_category works nicely with nested_attributes' do
        create_relationship = proc do
          Relationship.create!(category_id: 1, entity: person1, related: create(:entity_org), position_attributes: { is_board: true })
        end

        expect { create_relationship.call }.to change(Position, :count).by(1)
        expect(Position.last.is_board).to be true
      end
    end

    describe 'create_links' do
      it 'creates 2 links after creating relationship' do
        expect { Relationship.create!(category_id: 12, entity: person1, related: person2) }
          .to change(Link, :count).by(2)
      end
    end

    describe 'category_name' do
      it 'returns correct names' do
        expect(build(:position_relationship).category_name).to eql "Position"
        expect(build(:generic_relationship).category_name).to eql "Generic"
      end
    end

    describe 'category_name_display' do
      it 'returns correct names' do
        expect(build(:position_relationship).category_name_display).to eql "Position"
        expect(build(:generic_relationship).category_name_display).to eql "Generic"
        expect(build(:transaction_relationship).category_name_display).to eql "Transaction"
      end
    end

    describe 'attribute_fields_for' do
      it 'returns nil for category without fields' do
        expect(Relationship.attribute_fields_for(12)).to be nil
      end

      it 'returns correct_fields for position' do
        expect(Relationship.attribute_fields_for(1).to_set)
          .to eql [:is_board, :is_executive, :is_employee, :compensation, :boss_id].to_set
      end
    end

    describe 'get_category' do
      let(:donation_relationship) do
        create(:donation_relationship, entity: create(:entity_person), related: create(:entity_org))
      end

      let(:position_relationship) do
        Relationship
          .create!(category_id: 1, entity: create(:entity_person), related: create(:entity_org))
      end

      it 'returns nil if category does not have fields' do
        expect(build(:social_relationship).get_category).to be_nil
      end

      it 'returns category instance for donation relationship' do
        expect(donation_relationship.get_category).to eql donation_relationship.donation
      end

      it 'returns category instance for position relationship' do
        expect(position_relationship.get_category).to eql position_relationship.position
      end
    end
  end

  describe '#title' do
    let(:person) { create(:entity_person, :with_person_name) }
    let(:org) { create(:entity_org, :with_org_name) }

    it 'returns description1 if it exists' do
      rel = build(:position_relationship, description1: "dictator")
      expect(rel.title).to eql 'dictator'
    end

    it 'returns Board Member if the person is a board member' do
      rel = Relationship.create!(entity: person, related: org, category_id: 1)
      rel.position.update!(is_board: true)
      expect(rel.title).to eql 'Board Member'
    end

    it 'returns "Member" if the position is a membership category' do
      rel = Relationship.create!(entity: person, related: org, category_id: 3)
      expect(rel.title).to eql 'Member'
    end

    it 'returns degree if Education description1 is blank and there is a degree id' do
      rel = Relationship.create!(entity: person, related: org, category_id: 2)
      rel.education.update!(degree_id: 2)
      expect(rel.title).to eql 'Bachelor of Arts'
    end
  end

  describe 'Update Start/End dates' do
    let!(:entity1) { create(:entity_person) }
    let!(:entity2) { create(:entity_org) }
    let!(:donation) do
      create(:donation_relationship, entity: entity1, related: entity2, filings: 1, amount: 10_000, start_date: "2010-00-00", end_date: "2011-00-00")
    end

    specify do
      donation.update_start_date_if_earlier(Date.new(1999))
      expect(donation.reload.start_date).to eq '1999-01-01'
      donation.update_end_date_if_later(Date.new(2012))
      expect(donation.reload.end_date).to eq '2012-01-01'
      donation.update_start_date_if_earlier(Date.new(2010))
      expect(donation.reload.start_date).to eq '1999-01-01'
      donation.update_end_date_if_later Date.new(2010)
      expect(donation.reload.end_date).to eq '2012-01-01'
      donation.update_start_date_if_earlier nil
      expect(donation.start_date).to eq '1999-01-01'
      donation.update_end_date_if_later nil
      expect(donation.end_date).to eq '2012-01-01'
    end
  end

  describe '#update_contribution_info' do
    let(:loeb) { create(:entity_person) }
    let(:nrsc) { create(:entity_org) }

    let(:loeb_donation) do
      create(:donation_relationship, entity:  loeb, related: nrsc, filings: 1, amount: 10_000, start_date: "2010-00-00", end_date: "2011-00-00")
    end

    before do
      d1 = create(:loeb_donation_one)
      d2 = create(:loeb_donation_two)
      OsMatch.create!(relationship_id: loeb_donation.id, os_donation_id: d1.id, donor_id: loeb.id)
      OsMatch.create!(relationship_id: loeb_donation.id, os_donation_id: d2.id, donor_id: loeb.id)
      loeb_donation.update_os_donation_info
    end

    specify do
      expect(loeb_donation.amount).to eq 80_800
      expect(loeb_donation.filings).to eq 2
      expect(Relationship.find(loeb_donation.id).amount).not_to eql 80_800
    end

    it 'can be chained with .save' do
      loeb_donation.update_os_donation_info.save
      expect(Relationship.find(loeb_donation.id).amount).to eql 80_800
    end
  end

  describe '#update_ny_contribution_info' do
    before do
      donor = create(:entity_person, name: 'I <3 ny politicans')
      elected = create(:entity_org)
      ny_filer = create(:ny_filer)
      @rel = Relationship.create!(entity1_id: donor.id, entity2_id: elected.id, category_id: 5)
      disclosure1 = create(:ny_disclosure, amount1: 2000, schedule_transaction_date: '1999-01-01', ny_filer: ny_filer)
      disclosure2 = create(:ny_disclosure, amount1: 3000, schedule_transaction_date: '2017-01-01', ny_filer: ny_filer)
      create(:ny_match, ny_disclosure_id: disclosure1.id, donor_id: donor.id, recip_id: elected.id, relationship: @rel)
      create(:ny_match, ny_disclosure_id: disclosure2.id, donor_id: donor.id, recip_id: elected.id, relationship: @rel)
      @rel.update_ny_donation_info
    end

    specify do
      expect(@rel.amount).to eq 5_000
      expect(@rel.description1).to eql "NYS Campaign Contribution"
      expect(@rel.filings).to eq 2
      expect(@rel.start_date).to eq '1999-01-01'
      expect(@rel.end_date).to eq '2017-01-01'
    end

    it 'can be chained with .save to update the db' do
      expect(Relationship.find(@rel.id).attributes.slice('amount', 'filings'))
        .to eql("amount" => nil, "filings" => nil)
      @rel.update_ny_donation_info.save
      expect(Relationship.find(@rel.id).attributes.slice('amount', 'filings'))
        .to eql("amount" => 5000, "filings" => 2)
    end
  end

  describe '#name' do
    it 'generates correct title for position relationship' do
      rel = build(:relationship, category_id: 1, description1: 'boss')
      rel.position = build(:position, is_board: false)
      expect(rel.name).to eql "Position: Human Being, mega corp LLC"
    end

    context 'when relationship and entities have been deleted' do
      let(:entity) { create(:entity_person, :with_person_name) }
      let(:related) { create(:entity_org, :with_org_name) }
      let(:relationship) do
        Relationship.create!(category_id: 1, entity: entity, related: related)
      end
      let!(:name) { "Position: #{entity.name}, #{related.name}" }

      it 'generates title for deleted relationships' do
        expect(relationship.name).to eql name
        relationship.soft_delete
        entity.soft_delete
        related.soft_delete
        expect(relationship.name).to eql name
      end
    end
  end

  describe '#details' do
    describe 'it returns [ [field, value] ] for each Relationship type' do
      it 'Position' do
        rel = build(:relationship, category_id: 1, description1: 'boss', is_current: true)
        rel.position = build(:position, is_board: false)
        expect(rel.details)
          .to eql [['Title', 'boss'], ['Is Current', 'yes'], ['Board member', 'no']]
      end
    end
  end

  describe 'reverse functionality' do
    it 'membership relationships are reversible only when both are orgs' do
      expect(
        build(:membership_relationship, entity: build(:org), related: build(:org)).reversible?
      ).to be true

      expect(
        build(:membership_relationship, entity: build(:person), related: build(:org)).reversible?
      ).to be false
    end

    it 'position relationships are reversible only when both are people' do
      expect(
        build(:position_relationship, entity: build(:person), related: build(:person)).reversible?
      ).to be true

      expect(
        build(:position_relationship, entity: build(:person), related: build(:org)).reversible?
      ).to be false
    end

    it 'generic relationships are not reversible' do
      expect(build(:generic_relationship).reversible?).to be false
    end

    describe 'reverse_direction' do
      let(:person) { create(:entity_person) }
      let(:corp) { create(:entity_org) }
      let(:rel) do
        Relationship.create!(entity1_id: person.id, entity2_id: corp.id, category_id: 12)
      end

      def changes_direction_of_relationship(method, rel:, person:, corp:)
        expect(rel.entity1_id).to eql person.id
        expect(rel.entity2_id).to eql corp.id
        rel.public_send(method)
        expect(Relationship.find(rel.id).entity2_id).to eql person.id
        expect(Relationship.find(rel.id).entity1_id).to eql corp.id
      end

      def it_reverses_links(method, person:, rel:)
        expect(Link.where(entity1_id: person.id, relationship_id: rel.id)[0].is_reverse)
          .to be false
        expect(Link.where(entity2_id: person.id, relationship_id: rel.id)[0].is_reverse)
          .to be true
        rel.public_send(method)
        expect(Link.where(entity1_id: person.id, relationship_id: rel.id)[0].is_reverse)
          .to be true
        expect(Link.where(entity2_id: person.id, relationship_id: rel.id)[0].is_reverse)
          .to be false
      end

      describe '#reverse_direction' do
        it 'changes the direction of relationship' do
          changes_direction_of_relationship :reverse_direction, rel: rel, person: person, corp: corp
        end

        it 'reverses links' do
          it_reverses_links :reverse_direction, person: person, rel: rel
        end
      end

      describe '#reverse_direction!' do
        it 'changes the direction of relationship' do
          changes_direction_of_relationship :reverse_direction!, rel: rel, person: person, corp: corp
        end

        it 'reverses links' do
          it_reverses_links :reverse_direction!, person: person, rel: rel
        end
      end
    end
  end

  describe 'Similar Relationships' do
    let(:org) { create(:entity_org) }
    let(:person) { create(:entity_person) }

    it 'finds one relationship' do
      rel = Relationship.create!(entity: person, related: org, category_id: 1)
      similar_rels = Relationship.new(entity: person, related: org, category_id: 1).find_similar
      expect(similar_rels.length).to eq 1
      expect(similar_rels[0]).to eq rel
    end

    it 'checks both entity1 and entity2' do
      Relationship.create!(entity: person, related: org, category_id: 12)
      Relationship.create!(entity: org, related: person, category_id: 12)
      similar_rels = Relationship.new(entity: person, related: org, category_id: 12).find_similar
      expect(similar_rels.length).to eq 2
    end

    it 'returns empty array if no similar relationships are found' do
      similar_rels = Relationship.new(entity: person, related: org, category_id: 5).find_similar
      expect(similar_rels).to eq []
    end
  end

  describe 'as_json' do
    it 'does not contain last_user_id' do
      rel = build(:relationship, last_user_id: 900)
      expect(rel.as_json).not_to include 'last_user_id'
      expect(rel.as_json).not_to have_key 'url'
      expect(rel.as_json).not_to have_key 'name'
    end

    it 'contains "url" field with relationship url if options includes :url => true' do
      rel = build(:relationship, last_user_id: 900)
      expect(rel.as_json(:url => true)).to have_key 'url'
      expect(rel.as_json(:url => true)['url']).to eq Rails.application.routes.url_helpers.relationship_url(rel)
    end

    it 'contains "name" field if options includes :name => true' do
      org1 = build(:org, name: 'org1')
      org2 = build(:org, name: 'org2')
      rel = build(:relationship, last_user_id: 900, entity: org1, related: org2, category_id: 12)
      expect(rel.as_json(:name => true)).to have_key 'name'
      expect(rel.as_json(:name => true)['name']).to eq 'Generic: org1, org2'
    end
  end

  describe 'automatically setting is_current based on end_date' do
    let(:relationship) do
      create(:generic_relationship, entity1_id: create(:entity_person).id, entity2_id: create(:entity_person).id)
    end

    before { relationship }

    it 'changes is_current to false when end date is in the past' do
      expect(relationship.is_current).to be nil
      relationship.update!(end_date: (Time.zone.today - 1).iso8601)
      expect(relationship.is_current).to be false
    end

    it 'does not change is_current to false when end date is missing' do
      relationship.update!(start_date: '2000-01-01')
      expect(relationship.is_current).to be nil
    end

    it 'does not change is_current to false when end date is in the future' do
      relationship.update!(end_date: (Time.zone.today + 1).iso8601, is_current: true)
      expect(relationship.is_current).to be true
    end
  end

  describe 'DateSorting' do
    let(:entity1) { create(:entity_person) }
    let(:entity2) { create(:entity_person) }

    let(:current_relationship) do
      create(
        :generic_relationship,
        entity1_id: entity1.id,
        entity2_id: entity2.id,
        is_current: true,
        start_date: '1980-03-04',
        end_date: '2030-01-12',
        updated_at: '2016-07-14'
      )
    end

    let(:past_relationship) do
      create(
        :generic_relationship,
        entity1_id: entity1.id,
        entity2_id: entity2.id,
        is_current: false,
        end_date: nil
      )
    end

    let(:unknown_relationship) do
      create(
        :generic_relationship,
        entity1_id: entity1.id,
        entity2_id: entity2.id,
        is_current: nil
      )
    end

    it 'returns the correct temporal_status' do
      expect(current_relationship.temporal_status).to be :current
      expect(past_relationship.temporal_status).to be :past
      expect(unknown_relationship.temporal_status).to be :unknown
    end

    it 'returns the correct temporal_status_rank' do
      expect(current_relationship.temporal_status_rank).to be 2
      expect(past_relationship.temporal_status_rank).to be 0
      expect(unknown_relationship.temporal_status_rank).to be 1
    end

    it 'returns the correct end_date_rank' do
      expect(current_relationship.end_date_rank).to be 0
      expect(past_relationship.end_date_rank).to be 1
    end

    it 'ranks by temporal status, start date, end date rank, end date, updated at' do
      expect(current_relationship.date_rank).to match([2, '1980-03-04', 0, '2030-01-12', DateTime.parse('2016-07-14')])
    end
  end

  describe 'Deleting' do
    let(:rel) do
      create(:generic_relationship,
             entity1_id: create(:entity_person).id, entity2_id: create(:entity_person).id)
    end

    it 'soft_delete set is_deleted to be true' do
      expect(rel.is_deleted).to be false
      rel.soft_delete
      expect(rel.is_deleted).to be true
    end

    it 'soft_delete removes links' do
      rel
      expect { rel.soft_delete }.to change(Link, :count).by(-2)
    end

    it 'removing references for the relationship' do
      rel.add_reference(attributes_for(:document))
      expect { rel.soft_delete }.to change(Reference, :count).by(-1)
    end

    describe 'removing associated category models' do
      let(:person) { create(:entity_person) }
      let(:org) { create(:entity_org) }

      it 'removes position model' do
        rel = create(:position_relationship, entity1_id: person.id, entity2_id: org.id)
        expect { rel.soft_delete }.to change(Position, :count).by(-1)
      end

      it 'removes education model' do
        rel = Relationship.create!(category_id: 2, entity1_id: person.id, entity2_id: create(:entity_org).id)
        expect { rel.soft_delete }.to change(Education, :count).by(-1)
      end

      it 'removes membership model' do
        rel = Relationship.create!(category_id: 3, entity1_id: person.id, entity2_id: org.id)
        expect { rel.soft_delete }.to change(Membership, :count).by(-1)
      end

      it 'removes family model' do
        rel = Relationship.create!(category_id: 4, entity1_id: person.id, entity2_id: create(:person).id)
        expect { rel.soft_delete }.to change(Family, :count).by(-1)
      end

      it 'removes donation model' do
        rel = Relationship.create!(category_id: 5, entity1_id: person.id, entity2_id: org.id)
        expect { rel.soft_delete }.to change(Donation, :count).by(-1)
      end

      it 'removes transation model' do
        rel = Relationship.create!(category_id: 6, entity1_id: person.id, entity2_id: org.id)
        expect { rel.soft_delete }.to change(Transaction, :count).by(-1)
      end

      it 'removes ownership model' do
        rel = Relationship.create!(category_id: 10, entity1_id: person.id, entity2_id: org.id)
        expect { rel.soft_delete }.to change(Ownership, :count).by(-1)
      end

      it 'does nothing if deleting a generic relationship' do
        rel = Relationship.create!(category_id: 12, entity1_id: person.id, entity2_id: org.id)
        expect { rel.soft_delete }.not_to change(Position, :count)
      end
    end
  end

  describe 'restore!' do
    let(:person) { create(:entity_person) }
    let(:org) { create(:entity_org) }
    let(:rel) do
      Relationship.create!(entity: person, related: org, category_id: Relationship::POSITION_CATEGORY)
    end

    it 'raises error if called on a model that is not deleted' do
      expect { build(:relationship, is_deleted: false).restore! }.to raise_error(Exceptions::CannotRestoreError)
    end

    with_versioning do
      before { rel }

      it 'changes is_deleted status' do
        expect { rel.soft_delete }.to change { rel.is_deleted }.to(true)
        expect { rel.restore! }.to change { rel.is_deleted }.to(false)
      end

      # :create_category, :create_links, :update_entity_links
      it 'creates category' do
        expect { rel.soft_delete }.to change { Position.count }.by(-1)
        expect(rel.reload.position).to be nil
        expect { rel.restore! }.to change { Position.count }.by(1)
      end

      it 'creates links' do
        expect { rel.soft_delete }.to change { Link.count }.by(-2)
        expect { rel.restore! }.to change { Link.count }.by(2)
      end

      it 'it updates entity links' do
        # called twice: once after soft_delete and once after restore
        expect(rel).to receive(:update_entity_links).twice
        rel.soft_delete
        rel.restore!
      end

      it 'restores the reference' do
        document = create(:document)
        rel.add_reference(url: document.url)
        rel.soft_delete
        expect { rel.restore! }.to change(Reference, :count).by(1)
        expect(rel.references.count).to eql 1
        expect(rel.documents.count).to eql 1
        expect(rel.documents.first).to eq document
      end

      context 'entity1 is deleted' do
        let(:person) { create(:entity_person, is_deleted: true) }

        it 'does not restore the relationship' do
          rel.soft_delete
          expect { rel.restore! }.not_to change { rel.is_deleted }
          expect(rel.restore!).to be nil
        end
      end

      context 'entity2 is deleted' do
        let(:org) { create(:entity_person, is_deleted: true) }

        it 'does not restore the relationship' do
          rel.soft_delete
          expect { rel.restore! }.not_to change { rel.is_deleted }
          expect(rel.restore!).to be nil
        end
      end
    end
  end

  describe 'get_association_data' do
    let(:rel) { create(:generic_relationship, entity1_id: create(:entity_person).id, entity2_id: create(:entity_person).id) }
    let(:documents) { Array.new(2) { create(:document) } }

    it 'stores documents id in array' do
      documents.each { |d| rel.add_reference(url: d.url) }
      expect(rel.get_association_data).to have_key 'document_ids'
      expect(rel.get_association_data['document_ids'].to_set).to eql documents.map(&:id).to_set
    end
  end

  describe 'triplet' do
    let(:person) { create(:entity_person) }
    let(:person_two) { create(:entity_person) }
    let(:rel) { create(:generic_relationship, entity: person, related: person_two) }

    it 'returns array with entity ids and category id' do
      expect(rel.triplet).to eql([person.id, person_two.id, 12])
    end
  end

  describe 'permissions_for' do
    # let(:abilities) { UserAbilities.new(:edit) }
    # let(:user) { build(:user, abilities: abilities) }
    # let(:relationship) { build(:generic_relationship, created_at: Time.current) }
    # let(:permissions) { Permissions.new(user) }

    # let(:legacy_permissions) { [] }

    it 'deletable is false without a user' do
      expect(build(:relationship).permissions_for(nil)).to eq({ deleteable: false })
    end

    context 'when the user created the relationship' do
      let(:user) { build(:user_with_id, role: :editor) }

      let(:relationship) do
        build(:relationship, created_at: Time.current).tap do |r|
          allow(r).to receive_message_chain("versions.find_by").and_return(build(:relationship_version, event: 'create', whodunnit: user.id.to_s))
        end
      end

      specify 'when the relationship is new' do
        expect(relationship.permissions_for(user)).to eq({ deleteable: true })
        expect(relationship.permissions_for(build(:user_with_id, role: :editor))).to eq({ deleteable: false })
      end

      specify 'when the relationship is more than a week old' do
        relationship.created_at = 2.weeks.ago
        expect(relationship.permissions_for(user)).to eq({ deleteable: false })
        expect(relationship.permissions_for(build(:user, role: :admin))).to eq({ deleteable: true })
      end

      specify 'when the relationship is a campaign contribution' do
        relationship.description1 = 'NYS Campaign Contribution'
        relationship.filings = 2
        expect(relationship.permissions_for(user)).to eq({ deleteable: false })
      end
    end
  end

  describe 'Using paper_trail for versioning' do
    let(:human) { create(:entity_person) }
    let(:corp) { create(:entity_org) }
    let(:rel) { Relationship.create!(entity1_id: human.id, entity2_id: corp.id, category_id: 12) }
    let(:document)  { create(:document) }

    with_versioning do
      it 'records created, modified, and deleted versions' do
        rel = Relationship.create!(entity1_id: human.id, entity2_id: corp.id, category_id: 12)
        expect(rel.versions.size).to eq(1)
        rel.description1 = "important connection"
        rel.save
        expect(rel.versions.size).to eq(2)
        expect(rel.versions.last.event).to eq('update')
        rel.destroy
        expect(rel.versions.size).to eq(3)
        expect(rel.versions.last.event).to eq('destroy')
      end

      it 'saves entity1 and entity2 metadata' do
        rel = Relationship.create!(entity1_id: human.id, entity2_id: corp.id, category_id: 12)
        rel.update(description1: 'x')
        expect(rel.versions.last.entity1_id).to eq human.id
        expect(rel.versions.last.entity2_id).to eq corp.id
      end

      it 'saves document ids in the association data column' do
        rel.add_reference(url: document.url)
        rel.soft_delete
        expect(YAML.safe_load(rel.versions.last.association_data))
          .to eql('document_ids' => [document.id])
      end
    end
  end

  describe 'donation currency validations' do
    let(:loeb) { create(:loeb) }
    let(:nrsc) { create(:nrsc) }

    context 'without specifying a currency' do
      let(:donation) { build(:loeb_donation, entity: loeb, related: nrsc, filings: 1, amount: 10_000) }
      let(:generic_relationship) { create(:generic_relationship, entity: loeb, related: nrsc) }

      it 'defaults to USD when there is an amount' do
        donation.valid?
        expect(donation.currency).to eq 'usd'
      end

      it 'defaults to nil when there is no amount' do
        donation.amount = nil
        donation.valid?
        expect(donation.currency).to be nil
      end

      it 'does not raise a validation error when there is no amount' do
        expect(generic_relationship.valid?).to be true
      end
    end

    context 'with a currency but no amount' do
      let(:donation) { build(:loeb_donation, entity: loeb, related: nrsc, filings: 1, amount: nil, currency: :usd) }

      it 'raises a validation error' do
        donation.valid?
        expect(donation.errors.full_messages).to include('Currency entered without an amount')
      end
    end

    context 'with a currency in uppercase' do
      let(:donation) do
        build(:donation_relationship, entity: build(:person), related: build(:org), amount: 1, currency: 'USD')
      end

      it 'downcases the currency before validation' do
        expect(donation.valid?).to be true
        expect(donation.currency).to eq 'usd'
      end
    end

    context 'with a currency and an amount' do
      let(:donation) { build(:loeb_donation, entity: loeb, related: nrsc, filings: 1, amount: 23_000, currency: :usd) }

      it 'is valid' do
        expect(donation.valid?).to be true
      end
    end

    context 'when validating currency codes' do
      let(:donation) { build(:loeb_donation, entity: loeb, related: nrsc, filings: 1, amount: 20_000, currency: :usd) }

      it 'accepts ISO codes' do
        expect(donation.valid?).to be true
      end

      it "raises a validation error when the code is invalid" do
        donation.currency = 'frog bats'
        donation.valid?
        expect(donation.errors.full_messages).to include("Currency frog bats is not a valid currency code")
      end
    end
  end
end
