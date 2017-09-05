# Refactoring notes:  github.com/public-accountability/littlesis-rails/pull/288
class Permissions
  ACCESS_OPEN = 0
  ACCESS_CLOSED = 1
  ACCESS_PRIVATE = 2
  ALL_PERMISSIONS = ["admin", "contributor", "editor", "deleter", "lister", "merger", "importer", "bulker", "talker", "contacter"].freeze

  ALL_PERMISSIONS.each do |permission_name|
    define_method("#{permission_name}?") do
      legacy_permission?(permission_name)
    end
  end

  def initialize(user)
    @user = user
    @sf_permissions = @user.sf_guard_user.permissions
  end

  def add_permission(resource_type, access_rules)
    update_permission(resource_type, access_rules, :union)
  end

  def remove_permission(resource_type, access_rules)
    update_permission(resource_type, access_rules, :difference)
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
  # NOTE(Tue 05 Sep 2017): see refactor notes linked at top of file...
  def update_permission(resource_type, access_rules, operation)
    permission = @user.user_permissions.find_or_create_by(resource_type: resource_type.to_s)
    klass = "Permissions::#{resource_type}AccessRules".constantize
    new_access_rules = klass.update(permission.access_rules, access_rules, operation).to_json
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
    return true if lister? && (list.access == ACCESS_OPEN)
    return false
  end

  def configure_list?(list)
    return true if admin? || (list.creator_user_id == @user.id)
    return false
  end

  # TAG HELPERS

  def edit_tag?(tag)
    return true unless tag.restricted?
    return true if owns_tag(tag.id)
    return false
  end

  def owns_tag(tag_id)
    @user.user_permissions.find_by(resource_type: 'Tag')
      &.access_rules&.fetch(:tag_ids)&.include?(tag_id)
  end

  # LEGACY HELPERS

  def legacy_permission?(name)
    @sf_permissions.include?(name)
  end

  class TagAccessRules

    InvalidOperationError = Exception.new("operation must be one of: [:union, :difference]")

    def self.update(old_rules, new_rules, operation)
      check operation
      old_ids = (old_rules&.fetch(:tag_ids) || []).to_set
      new_ids = new_rules.fetch(:tag_ids, []).to_set
      { tag_ids: old_ids.send(operation, new_ids).to_a }
    end

    def self.check(operation)
      raise InvalidOperationError unless %i[union difference].include?(operation)
    end
  end
end

