module EntityMatcher
  # Generators for Person and Org that
  # create Sphinx query strings
  module Query
    class Base < SimpleDelegator
      attr_reader :query
      alias to_s query

      def initialize(*args)
        super(*args)
        # components of the query to be separated by OR
        @parts = []
        # overwrite this method to
        # populate the @parts instance var
        run
        create_query
      end

      protected

      def run
        raise NotImplementedError
      end

      private

      def create_query
        @query = @parts
                   .uniq
                   .map { |x| surround(x) }
                   .join(' | ')
      end

      def surround(x)
        "(#{x})"
      end
    end

    class Person < Base
      # Fields on Person that we will delgate for easier access
      PERSON_FIELDS = %I[name_first name_last name_middle name_prefix name_suffix name_nick name_maiden].freeze
      delegate(*PERSON_FIELDS, to: :person)

      def run
        @parts << name
        @parts << first_last if first_last != name
        @parts << first_last_suffix if name_suffix.present?
        @parts << prefix_lastname if name_prefix.present?
      end

      private

      def prefix_lastname
        "#{name_prefix} #{name_last}"
      end

      def first_last_suffix
        "#{name_first} #{name_last} #{name_suffix}"
      end

      def first_last
        "#{name_first} #{name_last}"
      end
    end

    class Org < Base
    end
  end

  class Matcher < SimpleDelegator
    def potential_matches
    end

    def keyword_matches
    end

    def exact_name_matches
    end

    def fuzzy_name_matches
    end

    def common_relationships
    end
  end

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
