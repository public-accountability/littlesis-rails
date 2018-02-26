class EntityMatcher

  # +by_person_name+, +by_full_name+ and +by_org_name+
  # are legacy methods used in ForbesFourHundredImporter and EntityNameAddressCsvImporter,
  # which themselves are outdated import code that needs to be re-written.
  # Once those classes are removed or refactored, they can be removed from this class.

  def self.by_person_name
    raise NotImplementedError
  end

  def self.by_full_name
    raise NotImplementedError
  end

  def self.by_org_name
    raise NotImplementedError
  end
end

# OLD implementation:
=begin
def self.by_person_name(first, last, middle = nil, suffix = nil, nick = nil, maiden = nil)
    first = [first, nick] if nick
    last = [last, maiden] if maiden
    firsts = [first].concat(Person.same_first_names(first))

    matches = Entity.joins(:person).where(
      person: {
        name_first: firsts,
        name_last: last
      }
    ).where("entity.is_deleted = 0")

    if middle
      matches = matches.select do |e| 
        [nil, middle, middle[0]].include?(e.person.name_middle) or middle == e.person.name_middle[0] or e.person.name_middle.split(/\s/).include?(middle) or middle.split(/\s/).include?(e.person.name_middle)
      end
    end

    if suffix
      matches = matches.select { |e| [nil, suffix].include?(e.person.name_suffix) }
    end

    matches
  end

  def self.by_full_name(name)
    Entity.joins(:aliases).where("LOWER(entity.name) = ? OR LOWER(alias.name) = ?", name.downcase, name.downcase)
  end

  def self.by_org_name(name)
    matches = by_full_name(name)
    stripped = Org.strip_name(name, strip_geo = false)
    results = Entity.search "@(name,aliases) #{Riddle::Query.escape(stripped)} @primary_ext Org", per_page: 20, match_mode: :extended, with: { is_deleted: 0 }
    matches.concat(results).uniq(&:id)
  end

=end
