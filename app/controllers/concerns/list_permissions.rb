# frozen_string_literal: true

module ListPermissions
  extend ActiveSupport::Concern

  included do
    private

    def set_permissions
      @permissions = if current_user
                       current_user.permissions.list_permissions(@list)
                     else
                       Permissions.anon_list_permissions(@list)
                     end
    end

    def check_access(permission)
      raise Exceptions::PermissionError unless @permissions[permission]
    end
  end
end
