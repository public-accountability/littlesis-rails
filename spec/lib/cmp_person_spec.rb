require 'rails_helper'

describe Cmp::CmpPerson do
  let(:override) { {} }
  let(:attributes) do
    {
      cmpid: Faker::Number.number(6),
      fullname: 'Mr. Oil Executive',
      nationality: 'Canada',
      firstname: 'oil',
      lastname: 'Executive',
      middlename: nil,
      salutation: 'Mr.',
      suffix: nil,
      dob_2015: '',
      dob_2016: '1960',
      gender: 'M'
    }
  end

  subject { Cmp::CmpPerson.new(attributes.merge(override)) }

  before(:all) do
    ThinkingSphinx::Callbacks.suspend!
    @cmp_user = create_basic_user_with_ids(Cmp::CMP_USER_ID, Cmp::CMP_SF_USER_ID)
    @cmp_tag = Tag.create!("id" => Cmp::CMP_TAG_ID,
                           "restricted" => true,
                           "name" => "cmp",
                           "description" => "Data from the Corporate Mapping Project")
  end

  after(:all) do
    @cmp_tag.delete
    @cmp_user.sf_guard_user.delete
    @cmp_user.delete
    SfGuardUserPermission.delete_all
    ThinkingSphinx::Callbacks.resume!
  end

  describe 'import!' do
    context 'Entity is not already in the database' do
      before do
        allow(subject). to receive(:preselected_match).and_return(nil)
        expect(EntityMatcher)
          .to receive(:find_matches_for_person).and_return(EntityMatcher::EvaluationResultSet.new([]))
      end

      it 'creates a new entity' do
        expect { subject.import! }.to change { Entity.count }.by(1)
        expect(Entity.last.name).to eql "Mr. Oil Executive"
      end
    end
  end
  

  describe '#attrs_for' do
    specify do
      expect(subject.send(:attrs_for, :entity))
        .to eql LsHash.new(name: 'Mr. Oil Executive')
    end
  end
end
