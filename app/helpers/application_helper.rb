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

  def more_link(content, max=200, id=nil)
  	splitter = "<!-- more -->"
  	if content.include? splitter
	  	id = SecureRandom.hex(8) if id.blank?
  		preview, remainder = content.split(splitter)
  		str = "<div id='#{id}_preview'>"
  		str << preview
  		str << "</div><div style='display: none;' id='#{id}_remainder'>"
  		str << remainder
  		str << "</div>"
  		str << "<a class='more_link' data-target='#{id}' href='javascript:void(0);'>more &raquo;</a>"
  		raw str
  	else
  	 content
  	end
  end

  def yes_or_no(value)
  	value ? "yes" : "no"
  end

  def check_mark(value=true)
		value ? raw("&#x2713;") : nil
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
