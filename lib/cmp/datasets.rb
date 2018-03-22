module Cmp
  module Datasets
    RELATIONSHIP_FILE_PATH = Rails.root.join('data', 'affiliations', 'affiliations.csv').to_s
    PERSON_FILE_PATH = Rails.root.join('data', 'CMP_Individuals.csv').to_s
    ORG_FILE_PATH = Rails.root.join('data', 'CMPDatabase2_Organizations_2015-2016.xlsx').to_s

    %I[people relationships orgs].each do |dataset_name|
      define_singleton_method(dataset_name) { dataset(dataset_name) }
    end

    def self.dataset(dataset)
      case dataset
      when :people
        @people_dataset ||= load_people
      when :relationships
        @relationships_dataset ||= load_relationships
      when :orgs
        @orgs_dataset ||= load_orgs
      else
        raise ArgumentError, 'Invalid dataset name'
      end
    end

    private_class_method def self.load_relationships
      Cmp::RelationshipSheet
        .new(RELATIONSHIP_FILE_PATH)
        .to_a.map { |attrs| CmpRelationship.new(attrs) }
    end

    private_class_method def self.load_people
      Cmp::PersonSheet
        .new(PERSON_FILE_PATH)
        .to_a.map { |attrs| CmpPerson.new(attrs) }
        .each_with_object({}) { |cmp_person, hash| hash.store(cmp_person.cmpid, cmp_person) }
    end

    private_class_method def self.load_orgs
      OrgSheet.new(ORG_FILE_PATH).to_a.map { |attrs| CmpOrg.new(attrs) }
    end
  end
end
