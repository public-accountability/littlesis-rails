require 'rails_helper'

describe 'RelationshipValidator' do
  class RelTester <
    include ActiveModel::Validations
    attr_accessor :entity1_id
    attr_accessor :entity2_id
    attr_accessor :category_id
    validates_with RelationshipValidator

    def entity; end

    def related; end

    def is_deleted_changed?; end

    def persisted?; end

  end

  describe 'Class Methods' do
    it 'has valid_categories' do
      expect(RelationshipValidator.valid_categories).to be_a Hash
      expect(RelationshipValidator.valid_categories).to have_key :person_to_person
      expect(RelationshipValidator.valid_categories).to have_key :person_to_org
      expect(RelationshipValidator.valid_categories).to have_key :org_to_org
      expect(RelationshipValidator.valid_categories).to have_key :org_to_person
    end

    it 'memoizes @valid_categories' do
      class TestRelationshipValidator < RelationshipValidator; end
      expect(RelationshipCategory).to receive(:valid_categories).once.and_return({})
      expect(TestRelationshipValidator.valid_categories).to be_a Hash
      expect(TestRelationshipValidator.valid_categories).to be_a Hash
    end

    it 'has person_to_person' do
      expect(RelationshipValidator.person_to_person).to be_a Array
      expect(RelationshipValidator.person_to_person.length).to be < 12
    end

    it 'has person_to_org' do
      expect(RelationshipValidator.person_to_org).to be_a Array
      expect(RelationshipValidator.person_to_org.length).to be < 12
    end

    it 'has org_to_org' do
      expect(RelationshipValidator.org_to_org).to be_a Array
      expect(RelationshipValidator.org_to_org.length).to be < 12
    end

    it 'has org_to_person' do
      expect(RelationshipValidator.org_to_person).to be_a Array
      expect(RelationshipValidator.org_to_person.length).to be < 12
    end
  end

  def tester(cat)
      rel = RelTester.new
      rel.entity1_id = 1
      rel.entity2_id = 2
      rel.category_id = cat
      rel
    end

  describe 'skipped validations' do
    it 'skips validations when a relationship has been soft deleted' do
      rel = tester(1)
      expect(rel).to receive(:is_deleted_changed?).and_return(true)
      expect(rel).to receive(:persisted?).and_return(true)
      expect(rel).not_to receive(:entity)
      expect(rel.valid?).to be true
    end
  end

  describe 'invalid relationships' do
    def person_double
      double('person double', :person? => true, :org? => false)
    end

    def org_double
      double('org double', :person? => false, :org? => true)
    end

    describe 'person to person set to Ownership' do
      before do
        @rel = tester(10)
        allow(@rel).to receive(:entity).and_return(person_double)
        allow(@rel).to receive(:related).and_return(person_double)
      end

      it 'sets relationship to be invalid' do
        expect(@rel.valid?).to eql false
      end

      it 'sets error message' do
        @rel.valid?
        expect(@rel.errors[:category]).to eq ["Ownership is not a valid category for Person to Person relationships"]
      end
    end

    describe 'person to org set to Family' do
      before do
        @rel = tester(4)
        allow(@rel).to receive(:entity).and_return(person_double)
        allow(@rel).to receive(:related).and_return(org_double)
      end

      it 'sets relationship to be invalid' do
        expect(@rel.valid?).to eql false
      end

      it 'sets error message' do
        @rel.valid?
        expect(@rel.errors[:category]).to eq ["Family is not a valid category for Person to Org relationships"]
      end
    end

    describe 'org to org set to Family' do
      before do
        @rel = tester(4)
        allow(@rel).to receive(:entity).and_return(org_double)
        allow(@rel).to receive(:related).and_return(org_double)
      end

      it 'sets relationship to be invalid' do
        expect(@rel.valid?).to eql false
      end

      it 'sets error message' do
        @rel.valid?
        expect(@rel.errors[:category]).to eq ["Family is not a valid category for Org to Org relationships"]
      end
    end

    describe 'org to person set to Position' do
      before do
        @rel = tester(1)
        allow(@rel).to receive(:entity).and_return(org_double)
        allow(@rel).to receive(:related).and_return(person_double)
      end

      it 'sets relationship to be invalid' do
        expect(@rel.valid?).to eql false
      end

      it 'sets error message' do
        @rel.valid?
        expect(@rel.errors[:category]).to eq ["Position is not a valid category for Org to Person relationships"]
      end
    end

    it "does't change vaidity if missing category_id" do
      rel = RelTester.new
      rel.entity1_id = 1
      rel.entity2_id = 2
      expect(rel.valid?).to be true
    end
  end
end
