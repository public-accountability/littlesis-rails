# frozen_string_literal: true

module ProfilePage
  def self.subcategory_name(subcategory)
    case subcategory
    when :board_members
      "Board Members"
    when :board_memberships
      "Board Memberships"
    when :businesses
      "Business Positions"
    when :campaign_contributions
      "Federal Election Campaign Contributions"
    when :campaign_contributors
      "Campaign Contributors"
    when :children
      "Child Organizations"
    when :donations
      "Donations"
    when :donors
      "Donors"
    when :family
      "Family"
    when :generic
      "Miscellaneous Relationships"
    when :governments
      "Government Positions"
    when :holdings
      "Holdings"
    when :lobbied_by
      "Lobbied By"
    when :lobbies
      "Lobbying"
    when :members
      "Members"
    when :memberships
      "Memberships"
    when :offices
      "In the office of"
    when :owners
      "Owners"
    when :parents
      "Parents"
    when :positions
      "Positions"
    when :schools
      "Schools"
    when :social
      "Social"
    when :staff
      "Leadership & Staff"
    when :students
      "Students"
    when :transactions
      "Services & Transactions"
    end
  end
end
