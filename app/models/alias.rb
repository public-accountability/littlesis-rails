class Alias < ApplicationRecord
  include SingularTable

  has_paper_trail on: [:create, :destroy],
                  meta: { entity1_id: :entity_id }

  belongs_to :entity, inverse_of: :aliases

  validates :entity_id, presence: true
  validates :name, length: { maximum: 200 }, presence: true

  before_validation :trim_name_whitespace

  # Makes this alias the primary alias
  # -> boolean
  def make_primary(user)
    return true if is_primary?

    self.class.transation do
      entity.primary_alias.update!(is_primary: false)
      update!(is_primary: true)
      entity.update! LsHash.new(name: name).with_last_user(user)
    end
    true
  rescue
    false
  end

  def name_regex(require_first = true)
    NameParser.parse_to_person(name).try(:name_regex, require_first)
  end

  private

  def trim_name_whitespace
    self.name = name.strip unless name.nil?
  end
end
