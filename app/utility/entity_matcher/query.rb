# frozen_string_literal: true

module EntityMatcher
  module Query
    def self.to_query(parts)
      parts
        .uniq
        .map { |x| "(#{x})" }
        .join(' | ')
    end

    def self.org_name(str)
      TypeCheck.check str, String

      name = OrgName.parse(str)

      parts = []

      parts << ThinkingSphinx::Query.wildcard(escape(name.clean))
      parts << escape(name.root) if escape(name.root) != escape(name.clean)

      if name.essential_words.length > 1
        parts << name.essential_words.map { |x| escape(x) }.join(' ')
      end

      to_query parts
    end

    def self.names(*args)
      if args.length.zero?
        raise ArgumentError
      elsif args.length == 1 && args.first.is_a?(Array)
        to_query(args.first.map { |name| wildcard(name) })
      else
        to_query(Array.wrap(args).map { |name| wildcard(name) })
      end
    end

    def self.entity(e)
      case e.primary_ext
      when 'Person'
        person_entity e
      when 'Org'
        org_name e.name
      else
        raise ArgumentError
      end
    end

    def self.person_entity(entity)
      parts = [entity.name, "#{entity.person.name_first} #{entity.person.name_last}"]

      if entity.person.name_suffix.present?
        parts << "#{entity.person.name_first} #{entity.person.name_last} #{entity.person.name_suffix}"
      end

      if entity.person.name_prefix.present?
        parts << "#{entity.person.name_prefix} #{entity.person.name_first} #{entity.person.name_last}"
      end

      to_query parts
    end

    def self.person_name(name)
      hash = NameParser.new(name).validate!.to_h
      parts = [name, "#{hash[:name_first]} #{hash[:name_last]}"]

      if hash[:name_suffix].present?
        parts << "#{hash[:name_first]} #{hash[:name_last]} #{hash[:name_suffix]}"
      end

      if hash[:name_prefix].present?
        parts << "#{hash[:name_prefix]} #{hash[:name_first]} #{hash[:name_last]}"
      end

      to_query parts
    end

    private_class_method def self.escape(x)
      ThinkingSphinx::Query.escape(x)
    end

    private_class_method def self.wildcard(x)
      ThinkingSphinx::Query.wildcard(x)
    end
  end
end
