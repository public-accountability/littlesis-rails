class Alias < ActiveRecord::Base
	include SingularTable
	
	belongs_to :entity, inverse_of: :aliases

  def name_regex(require_first = true)
    return nil unless person = NameParser.parse_to_person(name)
    person.name_regex(require_first)
  end
end