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
end
