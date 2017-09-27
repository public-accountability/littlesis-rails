module InterlocksExampleHelper
  def interlock_people_via_orgs(people, orgs)
    # person[0] is related to all orgs, person[n] is related to n orgs
    people.each_with_index do |person, idx|
      (idx.zero? ? orgs : orgs.take(idx)).each do |org|
        create(:position_relationship, entity: person, related: org)
      end
    end
  end
end
