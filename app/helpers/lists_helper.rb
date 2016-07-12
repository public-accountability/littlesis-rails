module ListsHelper
  def list_link(list, name=nil)
    name ||= list.name
    link_to(name, members_list_path(list))
  end

  def network_link(list)
    link_to(list.name, list.legacy_network_url)
  end

  def version_changes(changeset)
    changes = ""
    changeset.each_pair do |key, value| 
      changes += "<strong>#{key}:</strong> #{nil_string(value[0])} -> #{nil_string(value[1])}"
      changes += "<br>"
    end
    changes.html_safe
  end

  def nil_string(maybe_nil)
    if maybe_nil.nil?
      return "nil"
    else
      return maybe_nil
    end
  end
end
