# frozen_string_literal: true

# Permissions object for lists
List::Permissions = Struct.new(:viewable, :editable, :configurable, keyword_init: true) do
  # @param user [User, Nil]
  # @param list [List]
  def initialize(user:, list:)
    if user.nil?
      super(viewable: !list.restricted?, editable: false, configurable: false)
    else
      user_is_admin_or_owner = user.admin? || (list.creator_user_id == user.id)
      super(
        viewable: user_is_admin_or_owner || !list.restricted?,
        editable: user_is_admin_or_owner || (list.access == Permissions::ACCESS_OPEN && user.role.include?(:edit_list)),
        configurable: user_is_admin_or_owner
      )
    end
    freeze
  end
end
