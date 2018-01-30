module Cmp
  module Datasets
    RELATIONSHIP_FILE_PATH = Rails.root.join('data', 'affiliations', 'affiliations.csv').to_s
    PERSON_FILE_PATH = Rails.root.join('data', 'CMP_Individuals.csv').to_s

    def self.people
      dataset(:people)
    end

    def self.relationships
      dataset(:relationships)
    end

    def self.dataset(dataset)
      case dataset
      when :people
        @people_dataset ||= load_people
      when :relationships
        @relationships_dataset ||= load_relationships
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
  end
end
