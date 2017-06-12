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
  end

  describe 'Constants' do
    it 'has VALID_CATEGORIES constant' do
      expect(RelationshipValidator::VALID_CATEGORIES).to be_a Hash
      expect(RelationshipValidator::VALID_CATEGORIES).to have_key :person_to_person
      expect(RelationshipValidator::VALID_CATEGORIES).to have_key :person_to_org
      expect(RelationshipValidator::VALID_CATEGORIES).to have_key :org_to_org
      expect(RelationshipValidator::VALID_CATEGORIES).to have_key :org_to_person
    end

    it 'has other constants' do
      expect(RelationshipValidator::PERSON_TO_PERSON).to be_a Array
      expect(RelationshipValidator::PERSON_TO_ORG).to be_a Array
      expect(RelationshipValidator::ORG_TO_ORG).to be_a Array
      expect(RelationshipValidator::ORG_TO_PERSON).to be_a Array
    end
  end

  
  describe 'invalid relationships' do
    describe 'person to person set to Ownership' do
      before do
        @rel = RelTester.new
        @rel.entity1_id = 1
        @rel.entity2_id = 2
        @rel.category_id = 10
        expect(@rel).to receive(:entity).and_return(double(:person? => true))
        expect(@rel).to receive(:related).and_return(double(:person? => true))
      end
      
      it 'sets relationship to be invalid' do
        expect(@rel.valid?).to eql false
      end

      it 'sets error message' do
        @rel.valid?
        expect(@rel.errors[:category]).to eq ["Ownership is a not a valid category for Person to Person relationships"]
      end
      
    end
  end
  
end
