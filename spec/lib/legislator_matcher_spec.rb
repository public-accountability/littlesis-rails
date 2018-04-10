# frozen_string_literal: true

require 'rails_helper'
require Rails.root.join('lib', 'legislator_matcher')

describe 'LegislatorMatcher' do
  before(:all) do
    @legislators_current = YAML.load_file(
      Rails.root.join('spec', 'testdata', 'legislators-current.yaml')
    )
  end

  before(:each) do
    stub_current = Rails.root.join('spec', 'testdata', 'legislators-current.yaml').to_s
    stub_historical = Rails.root.join('spec', 'testdata', 'legislators-historical.yaml').to_s
    stub_const('LegislatorMatcher::CURRENT_YAML', stub_current)
    stub_const('LegislatorMatcher::HISTORICAL_YAML', stub_historical)
    stub_const('LegislatorMatcher::CONGRESS_BOT_USER', 1)
    stub_const('LegislatorMatcher::CONGRESS_BOT_SF_USER', 1)
  end

  subject { LegislatorMatcher.new }

  context 'initalize' do
    it 'sets current_reps and historical_reps' do
      expect(subject.current_reps.length).to eql 2
      expect(subject.historical_reps.length).to eql 2
    end

    it 'reps combines historical reps since 1990 and current ones' do
      expect(subject.reps.length).to eql 3
    end
  end

  context 'match_by_bioguide_or_govtrack' do
    let(:strange) { create(:entity_person, name: 'Luther Strange') }

    subject do
      LegislatorMatcher.new.reps.find { |r| r.dig('id', 'bioguide') == 'S001202' }
    end

    context 'bioguide in LittleSis' do
      before { strange.add_extension 'ElectedRepresentative', :bioguide_id => 'S001202' }

      it 'finds by bioguide' do
        expect(subject.match_by_bioguide_or_govtrack).to eql strange
      end
    end

    context 'govtrack in littleSis' do
      before { strange.add_extension 'ElectedRepresentative', :govtrack_id => '412734' }

      it 'finds by govtrack' do
        expect(subject.match_by_bioguide_or_govtrack).to eql strange
      end
    end

    context 'neither bioguide or govtrack in LittleSis' do
      before { strange.add_extension 'ElectedRepresentative' }

      it 'retuns nil' do
        expect(subject.match_by_bioguide_or_govtrack).to be_nil
      end
    end
  end

  describe LegislatorMatcher::Legislator do
    let(:sherrod_brown) { LegislatorMatcher::Legislator.new(@legislators_current[0]) }

    describe '#to_entity_attributes' do
      specify do
        expect(sherrod_brown.to_entity_attributes)
          .to eql(LsHash.new(name: 'Sherrod Brown',
                             blurb: 'US Senator from Ohio',
                             website: 'https://www.brown.senate.gov',
                             primary_ext: 'Person',
                             start_date: '1952-11-09',
                             last_user_id: LegislatorMatcher::CONGRESS_BOT_SF_USER))
      end
    end

    describe '#to_person_attributes' do
      specify do
        expect(sherrod_brown.to_person_attributes)
          .to eql(LsHash.new(name_first: 'Sherrod',
                             name_last: 'Brown',
                             gender_id: 2))
      end
    end

    describe '#to_elected_representative_attributes' do
      specify do
        expect(sherrod_brown.to_elected_representative_attributes)
          .to eql(LsHash.new(bioguide_id: 'B000944',
                             govtrack_id: 400_050,
                             fec_ids: %w[H2OH13033 S6OH00163],
                             crp_id: 'N00003535'))
      end
    end

    describe '#import!' do
      let(:import!) { proc { sherrod_brown.import! } }

      context "legislator doesn't exist in LittleSis" do
        before do
          sherrod_brown.instance_variable_set(:@_match, nil)
        end

        it 'creates a new entity' do
          expect { import!.call }.to change { Entity.count }.by(1)
        end

        it 'creates a person entity' do
          expect { import!.call }.to change { Person.count }.by(1)
        end

        it 'creates a new elected rep' do
          expect { import!.call }.to change { ElectedRepresentative.count }.by(1)
        end

        it 'correctly imports attributes' do
          import!.call
          entity = Entity.last
          expect(entity.name).to eql 'Sherrod Brown'
          expect(entity.person.gender).to eql 'Male'
          expect(entity.elected_representative.bioguide_id).to eql 'B000944'
          expect(entity.elected_representative.crp_id).to eql  'N00003535'
          expect(entity.elected_representative.fec_ids).to eql %w[H2OH13033 S6OH00163]
        end
      end

      context 'legislator exists in LittleSis - attributes changed' do
        let!(:entity) do
          create(:entity_person, name: 'Sherrod "nickname" Brown', blurb: 'i am sherrod brown')
            .tap { |e| e.add_extension('ElectedRepresentative', bioguide_id: 'B000944') }
        end

        it 'does not create a new entity' do
          expect { import!.call }.not_to change { Entity.count }
        end

        it 'updates entity attributes' do
          import!.call
          e = Entity.find(entity.id)
          expect(e.blurb).to eql 'i am sherrod brown'
          expect(e.start_date).to eql '1952-11-09'
          expect(e.person.gender).to eql 'Male'
          expect(e.aliases.count).to eql 2
          expect(e.also_known_as).to eql ['Sherrod Brown']
          expect(e.elected_representative.crp_id).to eql 'N00003535'
        end

        it 'does not update if none of the attributes have changed' do
          import!.call
          date = 1.year.ago
          entity.update_column(:updated_at, date)
          import!.call
          expect(Entity.find(entity.id).updated_at.to_i).to eql date.to_i
        end
      end
    end
  end

  describe LegislatorMatcher::TermsImporter do
    let(:sherrod_brown) { LegislatorMatcher::Legislator.new(@legislators_current[0]) }

    describe 'helper methods' do
      subject { LegislatorMatcher::TermsImporter.new(sherrod_brown) }

      specify { expect(subject.send(:rep_terms).length).to eql 7 }
      specify { expect(subject.send(:sen_terms).length).to eql 2 }
      specify { expect(subject.send(:distilled_terms).rep.length).to eql 1 }
      specify { expect(subject.send(:distilled_terms).sen.length).to eql 1 }

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

        specify do
          expect(subject.send(:distill, terms))
            .to eql([
                      { 'start' => '2000-01-01', 'end' => '2002-01-01', 'state' => 'NY', 'district' => 3, 'party' => 'Democrat'},
                      { 'start' => '2005-01-02', 'end' => '2006-01-01', 'state' => 'NY', 'district' => 3, 'party' => 'Democrat' },
                      { 'start' => '2006-01-02', 'end' => '2007-01-01', 'state' => 'NY', 'district' => 4, 'party' => 'Democrat' }
                    ])
          expect(subject.send(:distill, terms).length).to eql 3
        end
      end
    end # end describe helper methods

    xdescribe 'import!' do
      subject { LegislatorMatcher::TermsImporter.new(sherrod_brown) }
      context 'entity has no current relationships' do
        it 'creates 4 new relationships' do
          expect {  subject.import! }.to change { Relationship.count }.by(4)
        end

        it 'creates 4 new Memberhsip' do
          expect {  subject.import! }.to change { Membership.count }.by(4)
        end

        it 'created membership have correct fields'
      end

      context 'entity has one current relationship that matches' do
        it 'creates 3 new relationships' do
          expect {  subject.import! }.to change { Relationship.count }.by(3)
        end

        it 'creates 3 new Memberhsip' do
          expect {  subject.import! }.to change { Membership.count }.by(3)
        end

        it 'updates existing relationship'
      end

      context 'entity has one current relationship that matches and one totally incorrect relationship' do
        it 'creates 3 new relationships' do
          expect {  subject.import! }.to change { Relationship.count }.by(3)
        end

        it 'creates 3 new Memberhsip' do
          expect {  subject.import! }.to change { Membership.count }.by(3)
        end

        it 'updates existing relationship'

        it 'deletes incorrect relationship'
      end
    end
    
  end # end LegislatorMatcher::TermsImporter
end
