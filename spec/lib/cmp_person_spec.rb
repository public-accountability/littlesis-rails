require 'cmp'

describe Cmp::CmpPerson do
  let(:override) { {} }
  let(:attributes) do
    {
      cmpid: Faker::Number.number(digits: 6),
      fullname: 'Mr. Oil Executive',
      nationality: 'Canada;United Kingdom',
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
    @cmp_user = create_basic_user(id: Cmp::CMP_USER_ID)
    @cmp_tag = Tag.create!("id" => Cmp::CMP_TAG_ID,
                           "restricted" => true,
                           "name" => "cmp",
                           "description" => "Data from the Corporate Mapping Project")
  end

  after(:all) do
    @cmp_tag.delete
    @cmp_user.delete
    ThinkingSphinx::Callbacks.resume!
  end

  describe 'import!' do
    let(:oil_executive) { create(:entity_person, name: 'Oil Executive') }

    context 'Entity is not already in the database' do
      before do
        allow(subject).to receive(:preselected_match).and_return(nil)
        allow(Cmp::Datasets).to receive(:relationships).and_return([])

        expect(EntityMatcher)
          .to receive(:find_matches_for_person)
                .and_return(EntityMatcher::EvaluationResultSet.new([]))
      end

      it 'creates a new entity' do
        expect { subject.import! }.to change { Entity.count }.by(1)
        # expect(Entity.last.name).to eql 'Mr. Oil Executive'
      end

      it 'creates a new alias' do
        expect { subject.import! }.to change { Alias.count }.by(2)
        expect(Entity.last.also_known_as).to eql ['Mr. Oil Executive']
      end

      it 'creates a cmp entity' do
        expect { subject.import! }.to change { CmpEntity.count }.by(1)
      end

      it 'adds a taggings' do
        expect { subject.import! }.to change { Tagging.count }.by(1)
      end

      it 'sets correct person and entity fields' do
        subject.import!
        entity = Entity.last
        expect(entity.start_date).to eql '1960-00-00'
        expect(entity.person.gender_id).to eql 2
        expect(entity.person.name_prefix).to eql 'Mr.'
        expect(entity.person.nationality).to eql ['Canada', 'United Kingdom']
      end
    end

    context 'cmp entity exists already' do
      before do
        CmpEntity.create!(entity: oil_executive, cmp_id: attributes[:cmpid], entity_type: :person)
      end

      it 'does not create a new entity' do
        expect { subject.import! }.not_to change { Entity.count }
      end

      it 'does not create a new cmp entity' do
        expect { subject.import! }.not_to change { CmpEntity.count }
      end

      it 'creates a new alias' do
        expect { subject.import! }.to change { Alias.count }.by(1)
        expect(Entity.last.also_known_as).to eql ['Mr. Oil Executive']
      end

      it 'sets correct person and entity fields' do
        subject.import!
        entity = Entity.last
        expect(entity.start_date).to eql '1960-00-00'
        expect(entity.person.name_prefix).to eql 'Mr.'
      end
    end

    context 'preseleted matched given' do
      before { oil_executive }

      it 'does not create a entity entity' do
        expect { subject.import!(oil_executive.id.to_s) }.not_to change { Entity.count }
      end

      it 'creates a new cmp entity' do
        expect { subject.import!(oil_executive.id.to_s) }.to change { CmpEntity.count }.by(1)
      end
    end

    context 'preseleted = new' do
      before { oil_executive }

      it 'creates a entity entity' do
        expect { subject.import!(:new) }.to change { Entity.count }
      end

      it 'creates a new cmp entity' do
        expect { subject.import!(:new) }.to change { CmpEntity.count }.by(1)
      end
    end
  end

  describe '#attrs_for' do
    specify do
      expect(subject.send(:attrs_for, :entity))
        .to eq({ name: 'Mr. Oil Executive', start_date: '1960-00-00' }.with_indifferent_access)
    end
  end
end
