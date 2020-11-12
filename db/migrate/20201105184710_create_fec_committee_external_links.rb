class CreateFECCommitteeExternalLinks < ActiveRecord::Migration[6.0]
  def change
    PoliticalFundraising.where('fec_id is not null').find_each do |pf|

      if ExternalLink.fec_committee.exists? link_id: pf.fec_id
        Rails.logger.info "Political Fundraising #{pf.id} has a duplicate fec_id #{pf.fec_id}"
        next
      elsif pf.entity.nil?
        Rails.logger.info "Political Fundraising #{pf.id}'s entity is missing"
        next
      end

      pf.entity.external_links.fec_committee.create!(link_id: pf.fec_id)
    end
  end
end
