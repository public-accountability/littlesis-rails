module ApplicationHelper

	def centered_content(id=nil, &block)
		content_id = (id.nil? ? nil : id.to_s + "_content")
		str = content_tag("div", 
			content_tag("div", 
				"\n" + capture(&block) + "\n", 
				{ :class => "centered_content", :id => content_id },
				false
			), 
			{ :class => "centered", :id => id },
			false
		)			
		raw str
	end

  def more_link(content, max=nil, id=nil, make_raw=true)
  	splitter = "<!-- more -->"
  	if content.include? splitter or max.present?
	  	id = SecureRandom.hex(8) if id.blank?

      if content.include? splitter
    		preview, remainder = content.split(splitter)
      else
        full = strip_tags(content)
        preview = truncate(full, length: max, separator: ' ', escape: false, omission: '')
        remainder = full.gsub(preview, "")
      end

  		str = "<span id='#{id}_preview'>"
  		str << preview
  		str << "</span><span style='display: none;' id='#{id}_remainder'>"
  		str << remainder
  		str << "</span>"
  		str << " <a class='more_link' data-target='#{id}' href='javascript:void(0);'>more &raquo;</a>"
    else
      str = content
  	end

    make_raw ? raw(str) : str
  end

  def yes_or_no(value)
  	value ? "yes" : "no"
  end

  def check_mark(value=true)
		value ? raw("&#x2713;") : nil
  end

  def header_action(text, path)
    raw "<span class='btn btn-link btn-sm'>#{link_to text, path}</span>"
  end

  def legacy_login_path
    "/login"
  end

  def legacy_logout_path
    "/logout"
  end

  def legacy_signup_path
    "/join"
  end

  def home_groups_path
    "/home/groups"
  end

  def home_edits_path
    "/home/edits"
  end

  def home_settings_path
    "/home/settings"
  end
end
