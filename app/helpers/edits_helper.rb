################################################
# Helpers for modifications pages.
# used by edit controller and lists controller
################################################
module EditsHelper

  # Right now all this does is delete 'updated_at'
  def changeset_parse(changeset)
    changeset
      .dup # mutation scares me
      .tap { |x| x.delete('updated_at') } 
  end
  
  def version_changes(changeset)
    changes = ""
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
  
end
