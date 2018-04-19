require 'rails_helper'

describe Cmp::CmpRelationship do
  let(:cmp_org_id) { Faker::Number.unique.number(6) }
  let(:cmp_person_id) { Faker::Number.unique.number(6) }
  let(:attributes) do
    {
      cmpid:  "#{cmp_org_id}-#{cmp_person_id}",
      orbis: Faker::Lorem.characters(8),
      cmp_org_id: cmp_org_id,
      cmp_person_id: cmp_person_id,
      appointment_year: '2014',
      new_in_2016: '8',
      board_status_2016: '2',
      board_status_2015: '2',
      ex_status_2016: '0',
      ex_status_2015: '0',
      standardized_position: 'Director',
      job_title: 'Director (Board of Directors)'
    }
  end

  subject { Cmp::CmpRelationship.new(attributes) }

  describe 'initialize' do
    it 'sets @attributes' do
      expect(subject.attributes).to eql LsHash.new(attributes)
    end

    describe 'status' do
      context 'both years' do
        specify { expect(subject.status).to eql :both_years }
      end

      context 'only 2015' do
        before { attributes[:new_in_2016] = 0 }
        specify { expect(subject.status).to eql :only_2015 }
      end
    end
  end

  describe '#import!' do
    let(:org) { crete(:entity_org, :with_org_name) }
    let(:person) { crete(:entity_person, :with_person_name) }
    let(:cmp_entity_org) { create(:cmp_entity_org, entity: org, cmp_id: cmp_org_id) }
    let(:cmp_entity_person) { create(:cmp_person_org, entity: person, cmp_id: cmp_person_id) }

    context 'one relationship' do
      context 'relationship has already been imported' do
        it 'skips importing'
      end

      context 'relationship does not exist in littlesis' do
        it 'creates a new relationship' do
          expect { subject.import! }.to change { Relationship.count }.by(1)
        end
        it 'creates a new CmpRelationship'
        it 'correctly sets position attributes'
        it 'attributes the changes to the cmp user'
      end

      context 'matching relationship is in littlesis' do
        it 'does not create a new relationship'
        it 'updates existing relationship'
      end
    end
  end

  describe '#relationships' do
    it 'computes attributes for relationship' do
      expect(subject.relationships)
        .to eql [{ description1: 'Director (Board of Directors)',
                   is_current: nil,
                   start_date: '2014-00-00',
                   end_date: nil,
                   position_attributes: { is_board: true, is_executive: false } }]
    end

    context 'change in status' do
      before do
        attributes[:new_in_2016] = 1
        attributes[:ex_status_2016] = 1
      end

      it 'produces two relationship if required' do
        expect(subject.relationships.length).to eql 2
        expect(subject.relationships)
          .to eql([
                    {
                      description1: 'Director (Board of Directors)',
                      is_current: false,
                      start_date: '2014-00-00',
                      end_date: '2015-00-00',
                      position_attributes: { is_board: true, is_executive: false }
                    },
                    {
                      description1: 'Director (Board of Directors)',
                      is_current: nil,
                      start_date: '2016-00-00',
                      end_date: nil,
                      position_attributes: { is_board: true, is_executive: true }
                    }
                  ])
      end
    end
  end

  describe '#description1' do
    subject { Cmp::CmpRelationship.new(attributes).send(:description1) }

    context 'job title is less than 50 chars' do
      before { attributes[:job_title] = 'Vice President, Affairs' }
      specify { expect(subject).to eql 'Vice President, Affairs' }
    end

    context 'standard position has "COO"' do
      before  do
        attributes[:job_title] = ''
        attributes[:standardized_position] = '+Chief Operating Officer (COO)'
      end
      specify { expect(subject).to eql 'COO' }
    end

    context 'job title has ";"' do
      let(:title) { "Acting Executive Vice President for Marketing, Processing & Renewable Energy ); Senior Vice President, Marketing and Trading"}
      specify do
        expect(Cmp::CmpRelationship.new(attributes).send(:description1, title))
          .to eql 'Acting Executive Vice President for Marketing, Processing & Renewable Energy )'
      end
    end

    context 'job title has ","' do
      let(:title) { 'Director (Board of Directors), Member (Officers-Directors Compensation Committee)' }
      specify do
        expect(Cmp::CmpRelationship.new(attributes).send(:description1, title))
          .to eql 'Director (Board of Directors)'
      end
    end
  end

  xdescribe 'cmp_person' do
    context 'CmpEntity already exists in the database' do
      it 'returns the associated entity'
    end

    context 'Found a potential matching person' do
      it 'returns match'
    end

    context 'found no match' do
      it 'creates a new entity'
    end
  end
end
