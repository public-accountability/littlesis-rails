module CampaignsHelper
	def campaign_link(campaign)
		link_to campaign.name, campaign
	end
end
