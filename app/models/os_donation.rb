class OsDonation < ApplicationRecord
  has_paper_trail  :on => [:update, :destroy]  # don't track create events
  validates_uniqueness_of :fec_cycle_id

  has_one :os_match
  
  def create_fec_cycle_id
    unless self.cycle.nil? || self.fectransid.nil?
      self.fec_cycle_id = self.cycle + "_" + self.fectransid
    end
  end

  def reference_name
    "FEC Filing " + microfilm.to_s
  end

  def reference_source
    reference_url
  end

  def reference_url
    if microfilm.nil?
      "http://www.fec.gov/finance/disclosure/advindsea.shtml"
    else
      "http://docquery.fec.gov/cgi-bin/fecimg/?" + microfilm
    end
  end

end
