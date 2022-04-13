# frozen_string_literal: true

module ListPermissions
  extend ActiveSupport::Concern

  included do
    private

    def set_permissions
      @permissions = @list.permissions_for(current_user)
    end

    def check_access(permission)
      raise Exceptions::PermissionError unless @permissions[permission]
    end
  end
end
