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
        @relationship = create_relationship unless @dry_run
        @result = :relationship_created
      end
    else
      owner.add_to_matching_queue
      @result = :owner_not_matched
    end

    freeze
  end

  def relationship_exists?
  end

  def create_relationship
  end

  # Class Methods

  def self.create_relationships_for(advisor, dry_run: false)
    raise TypeError unless advisor.advisor?

    advisor.owners.map do |owner|
      new advisor: advisor, owner: owner, dry_run: dry_run
    end
  end
end
