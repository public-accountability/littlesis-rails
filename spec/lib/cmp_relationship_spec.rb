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

  describe '#relationships' do
    it 'computes attributes for relationship' do
      expect(subject.relationships)
        .to eql [{ description1: 'title',
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
                      description1: 'title',
                      is_current: false,
                      start_date: '2014-00-00',
                      end_date: '2015-00-00',
                      position_attributes: { is_board: true, is_executive: false }
                    },
                    {
                      description1: 'title',
                      is_current: nil,
                      start_date: '2016-00-00',
                      end_date: nil,
                      position_attributes: { is_board: true, is_executive: true }
                    }
                  ])
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
