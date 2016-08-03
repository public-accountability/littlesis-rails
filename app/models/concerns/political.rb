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
end
