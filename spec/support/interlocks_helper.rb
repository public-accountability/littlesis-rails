module InterlocksExampleHelper
  def interlock_people_via_orgs(people, orgs)
    # person[0] is related to all orgs, person[n] is related to n orgs
    people.each_with_index do |p, idx|
      org_subset = idx.zero? ? orgs : orgs.take(idx)
      org_subset.each { |o| create(:position_relationship, entity: p, related: o) }
    end
  end

  def interlock_orgs_via_people(orgs, people)
    # org[0] is related to all people, org[n] is related to n people
    orgs.each_with_index do |o, idx|
      people_subset = idx.zero? ? people : people.take(idx)
      people_subset.each { |p| create(:position_relationship, entity: p, related: o) }
    end
  end
end
