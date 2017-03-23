require 'rails_helper'

describe Person do
  it { should belong_to(:entity) }

  describe '#gender' do
    it 'returns correct gender for female, male, & other' do
      expect(build(:a_person, gender_id: 1).gender).to eq 'Female'
      expect(build(:a_person, gender_id: 2).gender).to eq 'Male'
      expect(build(:a_person, gender_id: 3).gender).to eq 'Other'
      expect(build(:a_person, gender_id: nil).gender).to be nil
    end
  end
end
