module InterlocksExampleHelper
  def interlock_people_via_orgs(people, orgs)
    # person[0] is the root of the interlocks tree and is related to all orgs
    # person[n] is a leaf of the interlocks tree and is related to n orgs
    people.each_with_index do |p, idx|
      org_subset = idx.zero? ? orgs : orgs.take(idx)
      org_subset.each { |o| create(:position_relationship, entity: p, related: o) }
    end
  end

  def interlock_orgs_via_people(orgs, people)
    # org[0] is the root of the interlocks tree and is related to all people
    # org[n] is a leaf of the interlocks tree and is related to n people
    orgs.each_with_index do |o, i|
      people_subset = i.zero? ? people : people.take(i)
      people_subset.each { |p| create(:position_relationship, entity: p, related: o) }
    end
  end
end
