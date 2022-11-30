# frozen_string_literal:true

class User
  class Role < Set
    attr_reader :name

    def initialize(name, enum = nil)
      @name = name.freeze
      super(enum)
      freeze
    end

    def to_s
      @name
    end

    DELETED = new('deleted')
    RESTRICTED = new('restricted', %i[login]) # Restricted users can do nothing but look
    USER = new('user', %i[login create_map create_list suggest_changes beta_testing])
    EDITOR = new('editor', USER.dup.merge(%i[edit_database upload star_relationship]))
    COLLABORATOR = new('collaborator', EDITOR.dup.merge(%i[bulk_upload match_donations create_tag merge_entity edit_list datasets]))
    ADMIN = new('admin', COLLABORATOR.dup.merge(%i[edit_destructively feature_items modify_permission approve_request edit_text]))
    SYSTEM = new('system', ADMIN.dup.delete(:login))  # system users cannot login

    def self.[](role)
      const_get(role.upcase)
    end
  end
end
