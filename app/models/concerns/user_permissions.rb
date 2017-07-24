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

    # Does the user have permssion to delete entities from given list?
    def delete_from_list?(list)
    end

    def legacy_permission?(name)
      @sf_permissions.include?(name)
    end

  end
end
