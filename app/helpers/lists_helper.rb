module ListsHelper
  def list_link(list, name=nil)
    name ||= list.name
    link_to(name, members_list_path(list))
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
