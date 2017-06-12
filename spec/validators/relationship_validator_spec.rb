require 'rails_helper'

describe 'RelationshipValidator' do
  class RelTester <
    include ActiveModel::Validations
    validates_with RelationshipValidator
  end

  describe 'VALID_CATEGORIES' do
    it 'has VALID_CATEGORIES constant' do
      expect(RelationshipValidator::VALID_CATEGORIES).to be_a Hash
      expect(RelationshipValidator::VALID_CATEGORIES).to have_key :person_to_person
      expect(RelationshipValidator::VALID_CATEGORIES).to have_key :person_to_org
      expect(RelationshipValidator::VALID_CATEGORIES).to have_key :org_to_org
      expect(RelationshipValidator::VALID_CATEGORIES).to have_key :org_to_person
    end
  end
end
