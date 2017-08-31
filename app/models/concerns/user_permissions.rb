module UserPermissions
  # extend ActiveSupport::Concern
  # included do
  # end

  ACCESS_OPEN = 0
  ACCESS_CLOSED = 1
  ACCESS_PRIVATE = 2

  def legacy_permissions
    sf_guard_user.permissions
  end

  def has_legacy_permission(name)
    sf_guard_user.has_permission(name)
  end

  def admin?
    has_legacy_permission 'admin'
  end

  def importer?
    has_legacy_permission 'importer'
  end

  def bulker?
    has_legacy_permission 'bulker'
  end

  def merger?
    has_legacy_permission 'merger'
  end

  def create_default_permissions
    unless has_legacy_permission('contributor')
      SfGuardUserPermission.create(permission_id: 2, user_id: sf_guard_user.id)
    end
    unless has_legacy_permission('editor')
      SfGuardUserPermission.create(permission_id: 3, user_id: sf_guard_user.id)
    end
  end

  def permissions
    @permissions ||= Permissions.new(self)
  end

  class TaggingAccessRules
    # (hash,hash) -> hash
    def self.update(old_rules, new_rules)
      old_ids = old_rules&.fetch(:tag_ids) || []
      new_ids = new_rules.fetch(:tag_ids, [])
      { tag_ids: old_ids | new_ids }
    end
  end

  class Permissions
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
      permission = @user.user_permissions.find_or_create_by(resource_type: resource_type.to_s)
      klass = "UserPermissions::#{resource_type}AccessRules".constantize
      new_access_rules = klass.update(permission.access_rules, access_rules).to_json
      permission.update(access_rules: new_access_rules)
    end

    def self.anon_tag_permissions(tagging)
      {
        viewable: true,
        editable: false,
      }
    end

    def tag_permissions(tagging)
      {
        viewable: true,
        editable: edit_tagging?(tagging)
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

    def edit_tagging?(tagging)
      return true unless Tag.find(tagging.tag_id).restricted?
      return true if owns_tag(tagging.tag_id)
      return false
    end

    def owns_tag(tag_id)
      @user.user_permissions.find_by(resource_type: 'Tagging')
      &.access_rules&.fetch(:tag_ids)&.include?(tag_id)
    end

    # LEGACY HELPERS

    def legacy_permission?(name)
      @sf_permissions.include?(name)
    end
  end
end
