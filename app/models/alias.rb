class Alias < ApplicationRecord
  include SingularTable
  extend WithoutPaperTrailVersioning
  attr_accessor :skip_update_entity_callback
  has_paper_trail on: [:create, :destroy],
                  meta: { entity1_id: :entity_id }

  belongs_to :entity, inverse_of: :aliases

  validates :entity_id, presence: true
  validates :name, length: { maximum: 200 }, presence: true

  before_validation :trim_name_whitespace

  after_create :update_entity_timestamp,
               unless: :skip_update_entity_callback

  after_destroy :update_entity_timestamp,
                unless: :skip_update_entity_callback

  # Makes this alias the primary alias
  # -> boolean
  def make_primary
    return true if is_primary?

    ApplicationRecord.transaction do
      entity.primary_alias.update!(is_primary: false)
      update!(is_primary: true)
      entity.update! LsHash.new(name: name).with_last_user(current_user_or_default)
    end
    true
  rescue => err # rubocop:disable Style/RescueStandardError
    Rails.logger.warn "Failed to make alias\##{id} primary"
    Rails.logger.debug err
    false
  end

  def name_regex(require_first = true)
    NameParser.parse_to_person(name).try(:name_regex, require_first)
  end

  private

  def trim_name_whitespace
    self.name = name.strip unless name.nil?
  end

  def update_entity_timestamp
    entity.touch_by(current_user_or_default)
  end

  def current_user_or_default
    current_user.presence || Rails.application.config.system_user_id
  end
end
