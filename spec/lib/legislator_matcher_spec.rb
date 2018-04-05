# frozen_string_literal: true

require 'rails_helper'
require Rails.root.join('lib', 'legislator_matcher')

describe 'LegislatorMatcher' do
  before(:each) do
    stub_current = Rails.root.join('spec', 'testdata', 'legislators-current.yaml').to_s
    stub_historical = Rails.root.join('spec', 'testdata', 'legislators-historical.yaml').to_s
    stub_const("LegislatorMatcher::CURRENT_YAML", stub_current)
    stub_const("LegislatorMatcher::HISTORICAL_YAML", stub_historical)
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
    before(:all) do
      @legislators_current = YAML.load_file Rails.root.join('spec', 'testdata', 'legislators-current.yaml')
    end
    let(:sherrod_brown) { LegislatorMatcher::Legislator.new(@legislators_current[0]) }

    describe '#to_entity_attributes' do
      specify do
        expect(sherrod_brown.to_entity_attributes)
          .to eql(LsHash.new(name: "Sherrod Brown",
                             blurb: "US Senator from Ohio",
                             website: "https://www.brown.senate.gov",
                             primary_ext: "Person",
                             start_date: "1952-11-09",
                             last_user_id: LegislatorMatcher::CONGRESS_BOT_SF_USER))
      end
    end

    describe '#to_person_attributes' do
      specify do
        expect(sherrod_brown.to_person_attributes)
          .to eql(LsHash.new(name_first: "Sherrod",
                             name_last: "Brown",
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
      context "legislator doesn't exist in LittleSis" do
        before do
          sherrod_brown.instance_variable_set(:@_match, nil)
        end

        let(:import!) { proc { sherrod_brown.import! } }

        it 'creates a new entity' do
          expect { import!.call }.to change { Entity.count }.by(1)
        end

        it 'creates a person entity' do
          expect { import!.call }.to change { Person.count }.by(1)
        end

        it 'creates a new elected rep' do
          expect { import!.call }.to change { ElectedRepresentative.count }.by(1)
        end
      end
    end
  end
end
