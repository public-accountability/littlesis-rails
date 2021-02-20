# frozen_string_literal: true

# rubocop:disable Layout/EmptyLineAfterGuardClause

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

  def add_permission(resource_type, access_rules)
    update_permission(resource_type, access_rules, :union)
  end

  def remove_permission(resource_type, access_rules)
    update_permission(resource_type, access_rules, :difference)
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

  def self.anon_tag_permissions
    {
      viewable: true,
      editable: false
    }
  end

  def tag_permissions(tag)
    {
      viewable: true,
      editable: edit_tag?(tag)
    }
  end

  def self.anon_list_permissions(list)
    {
      viewable: !list.restricted?,
      editable: false,
      configurable: false
    }
  end

  def list_permissions(list)
    {
      viewable: view_list?(list),
      editable: edit_list?(list),
      configurable: configure_list?(list)
    }
  end

  private

  # ACCESS RULE HELPER
  def update_permission(resource_type, access_rules, operation)
    permission = @user.user_permissions.find_or_create_by(resource_type: resource_type.to_s)
    klass = "Permissions::#{resource_type}AccessRules".constantize
    new_access_rules = klass.update(permission.access_rules, access_rules, operation)
    permission.update(access_rules: new_access_rules)
  end

  # LIST HELPERS

  def view_list?(list)
    return true if admin? || (list.creator_user_id == @user.id)
    return false if list.restricted?
    return true
  end

  # Does the user have permssion to add/remove entities from given list?
  def edit_list?(list)
    return true if admin? || (list.creator_user_id == @user.id)
    return false if list.restricted?
    return true if @user.lister? && (list.access == ACCESS_OPEN)
    return false
  end

  def configure_list?(list)
    return true if admin? || (list.creator_user_id == @user.id)
    return false
  end

  # TAG HELPERS

  def edit_tag?(tag)
    return true if @user.admin?
    return true unless tag.restricted?
    return true if owns_tag(tag.id)
    return false
  end

  def owns_tag(tag_id)
    @user.user_permissions.find_by(resource_type: 'Tag')
      &.access_rules&.fetch(:tag_ids)&.include?(tag_id)
  end

  # ENTITY HELPERS

  def delete_entity?(entity)
    return true if admin? || deleter?

    entity.created_at >= 1.week.ago &&
      entity.link_count < 3 &&
      user_is_creator?(entity)
  end

  def user_is_creator?(item)
    item.versions.find_by(event: 'create')&.whodunnit == @user.id.to_s
  end

  # RELATIONSHIP HELPERS

  def delete_relationship?(rel)
    return true if admin? || deleter?
    rel.created_at >= 1.week.ago &&
      !(rel.filings.present? && rel.description1.include?('Campaign Contribution')) &&
      user_is_creator?(rel)
  end

  class TagAccessRules
    InvalidOperationError = Exception.new('operation must be one of: [:union, :difference]')

    def self.update(old_rules, new_rules, operation)
      check operation
      old_ids = old_rules&.fetch(:tag_ids, [])&.to_set || Set.new
      new_ids = new_rules.fetch(:tag_ids, []).to_set
      { tag_ids: old_ids.send(operation, new_ids).to_a }
    end

    def self.check(operation)
      raise InvalidOperationError unless %i[union difference].include?(operation)
    end
  end
end

# rubocop:enable Layout/EmptyLineAfterGuardClause
