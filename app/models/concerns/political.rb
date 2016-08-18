module Political
  extend ActiveSupport::Concern
  # included do
  # end

  module ClassMethods
    def sqlize_array(arr)
      "('" + arr.join("','") + "')"
    end
  end
  
  def contribids
    contributions.pluck(:contribid).uniq
  end

  
  def potential_contributions
    before_query = "SELECT potential.* FROM ( "
    base_query = "SELECT * FROM os_donations WHERE (name_last = ? and name_first = ?)"
    after_query = " ) as potential LEFT JOIN os_matches on potential.id = os_matches.os_donation_id where os_matches.os_donation_id is null"
    n = NameParser.parse_to_hash(name)
    ids = contribids
    (base_query += " OR contribid IN #{self.class.sqlize_array(ids)}") if not ids.empty?
    
    OsDonation.find_by_sql [ "#{before_query}#{base_query}#{after_query}", n[:name_last], n[:name_first] ]
    
  end

  def contribution_info
    query = "SELECT os_matches.id as os_match_id, 
                    os_donations.*, 
                    entity.id as recip_id,
                    entity.name as recip_name,
                    entity.blurb as recip_blurb,
                    entity.primary_ext as recip_ext
             FROM os_matches 
             LEFT JOIN os_donations on os_matches.os_donation_id = os_donations.id 
             LEFT JOIN entity on os_matches.recip_id = entity.id
             WHERE os_matches.donor_id = ?"
    OsMatch.find_by_sql [ query, self.id ]
  end
end
