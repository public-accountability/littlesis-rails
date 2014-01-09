class GroupRequestMailer < ActionMailer::Base
  default( 
  	from: Lilsis::Application.config.default_from_email, 
  	to: Lilsis::Application.config.default_to_email,
  	content_type: "text/plain"
  )

  def notify_admin(group_request, user)
  	@name = group_request.name
  	@description = group_request.description
  	@user = user
  	@campaign = group_request.campaign
  	mail(subject: "New group requested by #{user.username}", content_type: "text/plain") do |format|
  		format.text
  	end
  end
end
