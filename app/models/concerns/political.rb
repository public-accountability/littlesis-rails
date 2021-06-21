# frozen_string_literal: true

module Political
  extend ActiveSupport::Concern

  module ClassMethods
    # Array -> String
    def name_query_string(names)
      query = ' (name_first = ? and name_last = ?) '
      if names.length == 1
        query
      else
        ([query] * names.length).join('OR')
      end
    end
  end

  def contribids
    contributions.pluck(:contribid).uniq.delete_if(&:blank?)
  end

  def contributions?
    contributions.present?
  end

  def aliases_names
    aliases.map { |a| NameParser.parse_to_hash(a.name) }
  end

  def potential_contributions
    names = aliases_names
    return [] unless names.length.positive?

    ids = contribids

    before_query = 'SELECT potential.* FROM ( '
    base_query = 'SELECT * FROM os_donations WHERE' + Entity.name_query_string(names)
    after_query = ') as potential LEFT JOIN os_matches on potential.id = os_matches.os_donation_id where os_matches.os_donation_id is null LIMIT 5000'
    base_query += " OR ( contribid IN #{ApplicationRecord.sqlize_array(ids)} )" unless ids.empty?

    OsDonation.find_by_sql(["#{before_query}#{base_query}#{after_query}"] + names.map { |name| [name[:name_first], name[:name_last]] }.flatten)
  end

  def contribution_info
    # If the entity is a person we just return matches for that person
    # If the entity is an org, we return all matches for all people who
    # hold position relationships with the org
    ids = person? ? Array.wrap(id) : links.where(category_id: 1).pluck(:entity2_id)
    OsMatch.find_by_sql Array.wrap(
              "SELECT os_matches.id as os_match_id,
                      os_donations.*,
                      entities.id as recip_id,
                      entities.name as recip_name,
                      entities.blurb as recip_blurb,
                      entities.primary_ext as recip_ext
                      #{org? ? ',donor.name as donor_name' : '' }
                      #{org? ? ',donor.id as donor_id' : '' }
               FROM os_matches
               LEFT JOIN os_donations on os_matches.os_donation_id = os_donations.id
               LEFT JOIN entities on os_matches.recip_id = entities.id
               #{org? ? 'LEFT JOIN entities as donor on os_matches.donor_id = donor.id' : '' }
               WHERE os_matches.donor_id IN #{self.class.sqlize_array(ids)}")
  end
end
