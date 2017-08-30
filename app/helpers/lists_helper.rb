module ListsHelper
  def list_link(list, name=nil)
    name ||= list.name
    link_to(name, members_list_path(list))
  end

  def tags_on_right?(tags)
    tags.count > 2
  end

  # For lists with less than 2 tags
  # they will appear appended to the list name.
  # Otherwise, they go in their own column on the right.
  def list_name_class(tags)
    tags_on_right?(tags) ? "col-sm-8 col-md-9" : "col-sm-12"
  end

  def network_link(list)
    link_to(list.name, list.legacy_network_url)
  end

  def nil_string(maybe_nil)
    if maybe_nil.nil?
      return "nil"
    else
      return maybe_nil
    end
  end
end
