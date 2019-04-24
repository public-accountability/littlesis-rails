# frozen_string_literal: true

# Creates or finds existing relationship between
# an Iapd Owner and Iapd Advisor
class IapdRelationshipService
  attr_reader :advisor, :owner, :dry_run, :result, :relationship

  def initialize(advisor:, owner:, dry_run: false)
    @advisor = advisor
    @owner = owner
    @dry_run = dry_run

    if owner.matched?
      if relationship_exists?
        @result = :relationship_exists
      else
        create_relationship unless @dry_run
        @result = :relationship_created
      end
    else
      @owner.add_to_matching_queue
      @result = :owner_not_matched
    end

    freeze
  end

  private

  # Checks if a proper relationship exists between the advisor and owner
  # sets @relationships
  # return Boolean
  def relationship_exists?
    @relationship = self.class.find_relationship(adivsor: @advisor, owner: @owner)
    @relationship.present?
  end

  # creates and returns relationship
  # sets @relationship
  def create_relationship
    @relationship = self.class.create_relationship(adivsor: @advisor, owner: @owner)
  end

  # Class Methods

  # Creates relationship between adivsor and owner
  # No duplicate check is done. Use find_relationship to find existing relationship
  # --> <Relationship>
  def self.create_relationship(adivsor:, owner:)
  end

  # Returns relationship between advisor and owner (if one exists)
  # otherwise returns nil
  def self.find_relationship(adivsor:, owner:)
  end

  def self.create_relationships_for(advisor, dry_run: false)
    raise TypeError unless advisor.advisor?

    advisor.owners.map do |owner|
      new advisor: advisor, owner: owner, dry_run: dry_run
    end
  end
end
