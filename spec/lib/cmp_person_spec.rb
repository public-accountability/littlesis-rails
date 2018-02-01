require 'rails_helper'

describe Cmp::CmpPerson do
  let(:override) { {} }
  let(:attributes) do
    {
      cmpid: Faker::Number.number(6),
      fullname: 'Oil Executive',
      nationality: 'Canada',
      firstname: 'oil',
      lastname: 'Executive',
      middlename: nil,
      suffix: nil,
      dob_2015: '',
      dob_2016: '1960',
      gender: 'M'
    }
  end

  subject { Cmp::CmpPerson.new(attributes.merge(override)) }

  describe '#attrs_for' do
    specify do
      expect(subject.send(:attrs_for, :entity))
        .to eql LsHash.new(name: 'Oil Executive')
    end
  end
end
