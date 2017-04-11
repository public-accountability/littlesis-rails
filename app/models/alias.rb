class Alias < ActiveRecord::Base
  include SingularTable

  belongs_to :entity, inverse_of: :aliases, touch: true

  validates_presence_of :entity_id
  validates :name, length: { maximum: 200 }, presence: true

  # Makes this alias the primary alias
  # -> boolean
  def make_primary
    return true if is_primary?
    entity.primary_alias.update!(is_primary: false)
    update!(is_primary: true)
    entity.update!(name: name)
    true
  rescue
    false
  end

  def name_regex(require_first = true)
    return nil unless person = NameParser.parse_to_person(name)
    person.name_regex(require_first)
  end

end

