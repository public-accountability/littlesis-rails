module UserPermissions
  # extend ActiveSupport::Concern
  # included do
  # end

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

  class Permissions
    ALL_PERMISSIONS = ["admin", "contributor", "editor", "deleter", "lister", "merger", "importer", "bulker", "talker", "contacter"].freeze

    ALL_PERMISSIONS.each do |permission_name|
      define_method("#{permission_name}?") do
        legacy_permission?(permission_name)
      end
    end

    def initialize(user)
      @user = user
      @sf_permissions = @user.sf_guard_user.sf_guard_permissions.pluck(:name).uniq
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

    def view_list?(list)
      return true if admin? || (list.creator_user_id == @user.id)
      return false if list.restricted?
      return true
    end

    # Does the user have permssion to add/remove entities from given list?
    def edit_list?(list)
      return true if admin? || (list.creator_user_id == @user.id)
      return false if list.restricted?
      return true if lister? && (list.access == List::ACCESS_OPEN)
      return false
    end

    def configure_list?(list)
      return true if admin? || (list.creator_user_id == @user.id)
      return false
    end

    def legacy_permission?(name)
      @sf_permissions.include?(name)
    end
  end
end
