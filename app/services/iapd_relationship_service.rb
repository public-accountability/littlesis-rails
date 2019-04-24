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
    @relationship = self.class.find_relationship(advisor: @advisor, owner: @owner)
    @relationship.present?
  end

  # creates and returns relationship
  # sets @relationship
  def create_relationship
    @relationship = self.class.create_relationship(advisor: @advisor, owner: @owner)
  end

  # Class Methods

  # Creates relationship between adivsor and owner
  # Makes a few assumptions:
  #  - No duplicate check is done. Use `find_relationship` to find existing relationship
  #  - The owner must be  matched. Use `owner.matched?` to verify
  #  - The owner is a person and from schedule A
  #    Schedule B contains itermediate relationships, which aren't not yet handled
  #
  #  returns <Relationship>
  def self.create_relationship(advisor:, owner:)
    error! 'Invalid advisor or owner type' unless advisor.advisor? && owner.owner?
    error! 'Owner is not matched' unless owner.matched?
    error! 'Owner is an org' if owner.org?

    filing = owner.latest_filing_for_advisor(advisor.row_data.fetch('crd_number'))

    error! 'Owner is from schedule B' if filing.fetch('schedule') == 'B'
  end

  # Returns relationship between advisor and owner (if one exists)
  # otherwise returns nil
  def self.find_relationship(advisor:, owner:)
  end

  def self.create_relationships_for(advisor, dry_run: false)
    raise TypeError unless advisor.advisor?

    advisor.owners.map do |owner|
      new advisor: advisor, owner: owner, dry_run: dry_run
    end
  end

  private_class_method def self.error!(msg)
    raise IapdRelationshipError, "[IapdRelationshipService] #{msg}"
  end

  class IapdRelationshipError < Exceptions::LittleSisError; end
end
