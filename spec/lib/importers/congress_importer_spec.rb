require 'importers'

# rubocop:disable RSpec/NamedSubject

TEST_CURRENT_LEGISLATORS = YAML.load_file(Rails.root.join('spec/testdata/legislators-current.yaml')).freeze

describe 'CongressImporter' do
  subject { CongressImporter.new }

  let(:legislators_current) { TEST_CURRENT_LEGISLATORS }

  before do
    stub_current = Rails.root.join('spec/testdata/legislators-current.yaml').to_s
    stub_historical = Rails.root.join('spec/testdata/legislators-historical.yaml').to_s
    stub_const('CongressImporter::CURRENT_YAML', stub_current)
    stub_const('CongressImporter::HISTORICAL_YAML', stub_historical)
    stub_const('CongressImporter::CONGRESS_BOT_USER', 1)
  end

  describe 'initialize' do
    it 'sets current_reps and historical_reps' do
      expect(subject.current_reps.length).to eq 2
      expect(subject.historical_reps.length).to eq 2
    end

    it 'reps combines historical reps since 1990 and current ones' do
      expect(subject.reps.length).to eq 3
    end
  end

  describe CongressImporter::Legislator do
    let(:sherrod_brown) { CongressImporter::Legislator.new(legislators_current[0]) }

    describe 'helper methods' do
      specify '#person_attributes' do
        expect(sherrod_brown.send(:person_attributes))
          .to eq({ name_first: 'Sherrod',
                   name_last: 'Brown',
                   gender_id: 2 }.with_indifferent_access)
      end

      specify '#elected_representative_attributes' do
        expect(sherrod_brown.send(:elected_representative_attributes))
          .to eq({ bioguide_id: 'B000944',
                   govtrack_id: 400_050,
                   crp_id: 'N00003535' }.with_indifferent_access)
      end

      specify '#fec_ids' do
        expect(sherrod_brown.send(:fec_candidate_ids)).to eq %w[H2OH13033 S6OH00163]
      end
    end

    describe '#import!' do
      context "when the legislator doesn't exist in LittleSis" do
        before do
          allow(CongressImporter::LegislatorMatcher)
            .to receive(:new).and_return(double(entity: nil))
        end

        it 'creates a new entity' do
          expect { sherrod_brown.import! }.to change(Entity, :count).by(1)
        end

        it 'creates a person entity' do
          expect { sherrod_brown.import! }.to change(Person, :count).by(1)
        end

        it 'creates a new elected rep' do
          expect { sherrod_brown.import! }.to change(ElectedRepresentative, :count).by(1)
        end

        it 'correctly imports attributes' do
          sherrod_brown.import!
          entity = Entity.last
          expect(entity.name).to eql 'Sherrod Brown'
          expect(entity.person.gender).to eql 'Male'
          expect(entity.elected_representative.bioguide_id).to eql 'B000944'
          expect(entity.elected_representative.crp_id).to eql  'N00003535'
          # expect(entity.elected_representative.fec_ids).to eql %w[H2OH13033 S6OH00163]
        end

        it 'creates external links' do
          sherrod_brown.import!
          entity = Entity.last
          expect(entity.external_links.fec_candidate.count).to eq 2
          expect(entity.external_links.fec_candidate.map(&:link_id).to_set).to eq Set["H2OH13033", "S6OH00163"]
        end
      end

      describe 'legislator exists in LittleSis - attributes changed' do
        let!(:entity) do
          create(:entity_person, name: 'Sherrod "nickname" Brown', blurb: 'i am sherrod brown')
            .tap { |e| e.add_extension('ElectedRepresentative', bioguide_id: 'B000944') }
        end

        it 'does not create a new entity' do
          expect { sherrod_brown.import! }.not_to change(Entity, :count)
        end

        it 'updates entity attributes' do
          sherrod_brown.import!
          e = Entity.find(entity.id)
          expect(e.blurb).to eq 'i am sherrod brown'
          expect(e.start_date).to eq '1952-11-09'
          expect(e.person.gender).to eq 'Male'
          expect(e.aliases.count).to eq 2
          expect(e.also_known_as).to eq ['Sherrod Brown']
          expect(e.elected_representative.crp_id).to eq 'N00003535'
        end

        it 'does not update if none of the attributes have changed' do
          sherrod_brown.import!
          date = 1.year.ago
          entity.update_column(:updated_at, date)
          sherrod_brown.import!
          expect(Entity.find(entity.id).updated_at.to_i).to eql date.to_i
        end
      end
    end
  end

  describe CongressImporter::TermsImporter do
    let(:sherrod_brown) { CongressImporter::Legislator.new(legislators_current[0]) }

    let(:sherrod_brown_entity) do
      create(:entity_person, name: 'Sherrod Brown').tap do |e|
        e.add_extension 'ElectedRepresentative', :bioguide_id => 'B000944'
      end
    end

    describe 'helper methods' do
      let(:terms_importer) do
        CongressImporter::TermsImporter.new(sherrod_brown)
      end

      # subject {  }

      before do
        allow(CongressImporter::LegislatorMatcher)
          .to receive(:new).and_return(double(entity: build(:person, name: 'Sherrod Brown')))
      end

      specify { expect(terms_importer.send(:rep_terms).length).to eq 7 }
      specify { expect(terms_importer.send(:sen_terms).length).to eq 2 }
      specify { expect(terms_importer.send(:distilled_terms).rep.length).to eq 1 }
      specify { expect(terms_importer.send(:distilled_terms).sen.length).to eq 1 }

      describe 'distill' do
        let(:terms) do
          [
            { 'start' => '2000-01-01', 'end' => '2001-01-01', 'state' => 'NY', 'district' => 3, 'party' => 'Democrat' },
            { 'start' => '2001-01-02', 'end' => '2002-01-01', 'state' => 'NY', 'district' => 3, 'party' => 'Democrat' },
            # ^^ should get combined because the start date is one past the end date
            { 'start' => '2005-01-02', 'end' => '2006-01-01', 'state' => 'NY', 'district' => 3, 'party' => 'Democrat' },
            # ^^ should be it's own relationship because the start state skips a few years
            { 'start' => '2006-01-02', 'end' => '2007-01-01', 'state' => 'NY', 'district' => 4, 'party' => 'Democrat' }
            # ^^ should be it's own relationship because the district changes
          ]
        end

        let(:sen_terms) do
          [
            { 'type' => 'sen', 'start' => '2009-01-06', 'end' => '2015-01-03',
              'state' => 'AL', 'class' => 3, 'party' => 'Republican',
              'url' => 'http://www.sessions.senate.gov' },
            { 'type' => 'sen', 'start' => '2015-01-06', 'end' => '2017-02-08',
              'state' => 'AL', 'class' => 2, 'party' => 'Republican',
              'url' => 'http://www.sessions.senate.gov/public',
              'address' => '326 Russell Senate Office Building Washington DC 20510' }
          ]
          # Classes changes from 3 -> 2, url changes, and address is added
        end

        specify do
          expect(terms_importer.send(:distill, terms))
            .to eq([
                     { 'start' => '2000-01-01', 'end' => '2002-01-01', 'state' => 'NY', 'district' => 3, 'party' => 'Democrat' },
                     { 'start' => '2005-01-02', 'end' => '2006-01-01', 'state' => 'NY', 'district' => 3, 'party' => 'Democrat' },
                     { 'start' => '2006-01-02', 'end' => '2007-01-01', 'state' => 'NY', 'district' => 4, 'party' => 'Democrat' }
                   ])
          expect(terms_importer.send(:distill, terms).length).to eq 3
        end

        specify do
          expect(terms_importer.send(:distill, sen_terms))
            .to eq([
                     { 'type' => 'sen', 'start' => '2009-01-06', 'end' => '2017-02-08',
                       'state' => 'AL', 'class' => 2, 'party' => 'Republican',
                       'url' => 'http://www.sessions.senate.gov/public',
                       'address' => '326 Russell Senate Office Building Washington DC 20510' }
                   ])
          expect(terms_importer.send(:distill, sen_terms).length).to eq 1
        end
      end

      describe '#distill_party_membership' do
        let(:terms) do
          [
            { 'start' => '2000-01-01', 'end' => '2001-01-01', 'state' => 'NY', 'district' => 3, 'party' => 'Democrat' },
            { 'start' => '2001-01-02', 'end' => '2002-01-01', 'state' => 'NY', 'district' => 3, 'party' => 'Democrat' },
            { 'start' => '2005-01-02', 'end' => '2006-01-01', 'state' => 'NY', 'district' => 3, 'party' => 'Republican' },
            { 'start' => '2006-01-02', 'end' => '2007-01-01', 'state' => 'NY', 'district' => 4, 'party' => 'Democrat' },
            { 'start' => '2008-01-02', 'end' => '2010-01-01', 'state' => 'NY', 'district' => 4, 'party' => 'Green' }
          ]
        end

        specify do
          expect(terms_importer.send(:distill_party_memberships, terms))
            .to eql([
                      { 'start' => '2000-01-01', 'end' => '2002-01-01', 'party' => 'Democrat' },
                      { 'start' => '2005-01-02', 'end' => '2006-01-01', 'party' => 'Republican' },
                      { 'start' => '2006-01-02', 'end' => '2007-01-01', 'party' => 'Democrat' }
                    ])

          expect(terms_importer.send(:distill_party_memberships, terms).length).to eql 3
        end

        specify do
          expect(terms_importer.send(:party_memberships))
            .to eq([{ 'start' => '1993-01-05', 'end' => '2019-01-03', 'party' => 'Democrat' }])
        end
      end

      describe 'update_or_create_relationship' do
        let(:term) do
          { 'type' => 'rep', 'start' => '1993-01-05', 'end' => '2007-01-03', 'state' => 'OH', 'district' => 13, 'party' => 'Democrat' }
        end

        let(:update_or_create_relationship) do
          proc do
            sherrod_brown.terms_importer.send(:update_or_create_relationship, term)
          end
        end

        before do
          sherrod_brown_entity
          create(:us_house)
          create(:us_senate)
          allow(CongressImporter::LegislatorMatcher)
            .to receive(:new).and_return(double(entity: sherrod_brown_entity.reload))
          # sherrod_brown.match
        end

        it 'creates a new relationship' do
          expect(&update_or_create_relationship).to change(Relationship, :count).by(1)
        end

        it 'creates a new membership' do
          expect(&update_or_create_relationship).to change(Membership, :count).by(1)
        end

        it 'sets correct relationship fields' do
          update_or_create_relationship.call
          relationship = Relationship.last
          expect(relationship.entity).to eql sherrod_brown_entity
          expect(relationship.entity2_id).to eq 12_884
          expect(relationship.start_date).to eq '1993-01-05'
          expect(relationship.end_date).to eq '2007-01-03'
          expect(relationship.is_current).to eql false
          expect(relationship.description1).to eq 'Representative'
          expect(relationship.description2).to eq 'Representative'
          expect(relationship.last_user_id).to eq CongressImporter::CONGRESS_BOT_USER
        end

        it 'sets membership.elected_term to be an OpenStruct of term information' do
          update_or_create_relationship.call
          expect(Relationship.last.membership.elected_term).to eql term.merge('source' => '@unitedstates')
        end
      end
    end # end describe helper methods

    describe 'import!' do
      subject { CongressImporter::TermsImporter.new(sherrod_brown) }

      before do
        create(:us_house)
        create(:us_senate)
        sherrod_brown_entity
        allow(CongressImporter::LegislatorMatcher)
          .to receive(:new).and_return(double(entity: sherrod_brown_entity.reload))
      end

      let(:sen_term) do
        { 'type' => 'sen',
          'start' => '2007-01-04',
          'end' => '2019-01-03',
          'state' => 'OH',
          'party' => 'Democrat',
          'class' =>  1,
          'url' =>  'https://www.brown.senate.gov',
          'address' => '713 Hart Senate Office Building Washington DC 20510',
          'phone' => '202-224-2315',
          'fax' => '202-228-6321',
          'contact_form' => 'http://www.brown.senate.gov/contact/',
          'office' => '713 Hart Senate Office Building',
          'state_rank' => 'senior',
          'rss_url' => 'http://www.brown.senate.gov/rss/feeds/?type=all&amp;',
          'source' => '@unitedstates' }
      end

      context 'when the entity has no current relationships' do
        it 'creates 2 new relationships' do
          expect { subject.import! }.to change(Relationship, :count).by(2)
        end

        it 'creates 2 new Memberhsip' do
          expect { subject.import! }.to change(Membership, :count).by(2)
        end

        it 'created membership have correct fields' do
          subject.import!
          expect(sherrod_brown_entity.relationships.find_by(entity2_id: 12_884).membership.elected_term)
            .to eq('type' => 'rep', 'start' => '1993-01-05', 'end' => '2007-01-03',
                   'state' => 'OH', 'district' => 13, 'party' => 'Democrat',
                   'url' => 'http://www.house.gov/sherrodbrown', 'source' => '@unitedstates')

          expect(sherrod_brown_entity.relationships.find_by(entity2_id: 12_885).membership.elected_term)
            .to eq sen_term

          expect(sherrod_brown_entity.relationships.find_by(entity2_id: 12_885).is_current).to eq false
        end
      end

      context 'when the entity has one current relationship that matches' do
        let!(:relationship) do
          Relationship.create!(category_id: 3, start_date: '1993-01-00', entity: sherrod_brown_entity, entity2_id: 12_884)
        end

        it 'creates 1 new relationships' do
          expect { subject.import! }.to change(Relationship, :count).by(1)
        end

        it 'creates 1 new Memberhsip' do
          expect { subject.import! }.to change(Membership, :count).by(1)
        end

        it 'updates existing relationship' do
          subject.import!
          relationship.reload
          expect(relationship.end_date).to eql '2007-01-03'
          expect(relationship.membership.elected_term['party']).to eql 'Democrat'
        end
      end

      context 'entity has one current relationship that matches and one totally incorrect relationship' do
        let!(:relationship) do
          Relationship.create!(category_id: 3, start_date: '1993-01-00', entity: sherrod_brown_entity, entity2_id: 12_884)
        end

        let!(:invalid_relationship) do
          Relationship.create!(category_id: 3, start_date: '1950-01-01', entity: sherrod_brown_entity, entity2_id: 12_884)
        end

        it 'creates 0 new relationships' do
          expect { subject.import! }.not_to change(Relationship, :count)
        end

        it 'updates existing relationship' do
          subject.import!
          relationship.reload
          expect(relationship.end_date).to eql '2007-01-03'
        end

        it 'deletes incorrect relationships' do
          subject.import!
          invalid_relationship.reload
          expect(invalid_relationship.is_deleted).to be true
          expect(Relationship.where(entity: sherrod_brown_entity, entity2_id: 12_884).count).to eq 1
          expect(Relationship.where(entity: sherrod_brown_entity, entity2_id: 12_885).count).to eq 1
          expect(sherrod_brown_entity.reload.relationships.count).to eq 2
        end
      end
    end # end describe 'import!'

    describe '#import_party_memberships!' do
      subject { CongressImporter::TermsImporter.new(sherrod_brown) }

      before do
        sherrod_brown_entity
        create(:democratic_party)
        allow(CongressImporter::LegislatorMatcher)
          .to receive(:new).and_return(double(entity: sherrod_brown_entity.reload))
      end

      context 'when party membership is not yet in LittleSis' do
        it 'creates a new relationship' do
          expect { subject.import_party_memberships! }.to change(Relationship, :count).by(1)
          expect(Relationship.last.entity2_id).to eq 12_886
        end
      end

      context 'when party membership is already in LittleSis' do
        before do
          Relationship.create!(entity: sherrod_brown_entity, entity2_id: 12_886, category_id: 3)
        end

        it 'does not create a new relationship' do
          expect { subject.import_party_memberships! }.not_to change(Relationship, :count)
        end
      end
    end
  end # end CongressImporter::TermsImporter
end

# rubocop:enable RSpec/NamedSubject
