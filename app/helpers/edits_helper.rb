# frozen_string_literal: true

################################################
# Helpers for modifications pages.
# used by edit controller, lists controller, and users controller
################################################
module EditsHelper
  # Right now all this does is delete: 'updated_at', 'last_user_id', 'id'
  def changeset_parse(changeset)
    changeset_hash = changeset.dup # mutation is scary
    ['updated_at', 'last_user_id', 'id', 'created_at'].each do |key|
      changeset_hash.delete(key)
    end
    changeset_hash
  end

  def version_changes(changeset)
    changes = +""
    changeset_parse(changeset).each_pair do |key, value|
      changes += "<strong>#{key}:</strong> #{nil_string(value[0])} -> #{nil_string(value[1])}"
      changes += "<br>"
    end
    changes.html_safe
  end

  def who_did_it(version)
    return '?' if version.whodunnit.blank?
    user = User.find_by_id(version.whodunnit)
    return '?' if user.nil?
    user.username
  end

  def resource_link_or_text(resource)
    if resource.respond_to?(:is_deleted) && resource.is_deleted
      content_tag(:span, resource.name) + content_tag(:em, ' (deleted)')
    else
      link_to resource.name, send("#{resource.class.name.downcase}_path", resource)
    end
  end
end
