module NetworkAnalysisExampleHelper
  def interlock_people_via_orgs(people, orgs)
    # person[0] works at all orgs, person[n] works at n orgs
    people.each_with_index do |p, idx|
      org_subset = idx.zero? ? orgs : orgs.take(idx)
      org_subset.each { |o| create(:position_relationship, entity: p, related: o) }
    end
  end

  def interlock_orgs_via_people(orgs, people)
    # org[0] employs all people, org[n] employs n people
    orgs.each_with_index do |o, i|
      people_subset = i.zero? ? people : people.take(i)
      people_subset.each { |p| create(:position_relationship, entity: p, related: o) }
    end
  end

  def create_donations_from(donors, recipients)
    # donor[0] gives to all recipients, donor[n] gives to n recipients
    donors.each_with_index do |p, idx|
      recipients_subset = idx.zero? ? recipients : recipients.take(idx)
      recipients_subset.each { |o| create(:donation_relationship, entity: p, related: o) }
    end
  end

  def create_donations_to(recipients, donors)
    # recipient[0] gets money from no donors, recipient[n] gets money from n donors
    recipients.each_with_index do |o, idx|
      next if idx.zero?
      donors.take(idx).each do |p|
        create(:donation_relationship, entity: p, related: o, amount: (idx * 100))
      end
    end
  end
end
