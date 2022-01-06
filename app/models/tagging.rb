# frozen_string_literal: true

class Tagging < ApplicationRecord
  GET_TAGABLE_ID_IF_ENTITY = proc { |t| t.tagable_id if t.tagable_class == 'Entity' }
  private_constant :GET_TAGABLE_ID_IF_ENTITY

  has_paper_trail meta: { entity1_id: GET_TAGABLE_ID_IF_ENTITY },
                  on:  %i[create destroy update],
                  versions: { class_name: 'ApplicationVersion' }

  belongs_to :tagable, polymorphic: true, foreign_type: :tagable_class, optional: true
  belongs_to :last_user, class_name: "User", foreign_key: "last_user_id"
  validates_presence_of :tag_id, :tagable_class, :tagable_id

  belongs_to :tag

  after_save :update_tagable_timestamp
  after_save :populate_to_sphinx
  after_destroy :populate_to_sphinx

  # TODO: replace this with touch_by
  def update_tagable_timestamp(last_user_id = Rails.application.config.littlesis[:system_user_id])
    if tagable.last_user_id == last_user_id
      tagable.touch
    else
      tagable.update(last_user_id: last_user_id)
    end
  end

  # see https://freelancing-gods.com/thinking-sphinx/v5/indexing.html#callbacks
  def populate_to_sphinx
    return unless tagable_class == 'Entity'

    ThinkingSphinx::RealTime::Callbacks::RealTimeCallbacks
      .new(:entity, [:tagable])
      .after_save(self)
  end
end
