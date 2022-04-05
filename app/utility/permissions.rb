# frozen_string_literal: true

class Permissions
  ACCESS_OPEN = 0
  ACCESS_CLOSED = 1
  ACCESS_PRIVATE = 2

  ACCESS_MAPPING = {
    0 => 'Open',
    1 => 'Closed',
    2 => 'Private'
  }.freeze

  delegate(*UserAbilities::ABILITY_MAPPING.values, to: '@user.abilities')

  def initialize(user)
    @user = user
  end

  def entity_permissions(entity)
    {
      mergeable: admin?,
      deleteable: delete_entity?(entity)
    }
  end

  def relationship_permissions(rel)
    { deleteable: delete_relationship?(rel) }
  end

  private

  # RELATIONSHIP HELPERS

  def delete_relationship?(rel)
    return true if admin? || deleter?
    rel.created_at >= 1.week.ago &&
      !(rel.filings.present? && rel.description1.include?('Campaign Contribution')) &&
      user_is_creator?(rel)
  end
end
