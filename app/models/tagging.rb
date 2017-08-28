class Tagging < ActiveRecord::Base
  DEFAULT_LAST_USER_ID = APP_CONFIG.fetch('system_user_id')
  belongs_to :tagable, polymorphic: true, foreign_type: :tagable_class
  validates_presence_of :tag_id, :tagable_class, :tagable_id

  after_save :update_tagable_timestamp

  def update_tagable_timestamp(last_user_id = DEFAULT_LAST_USER_ID)
    if tagable.last_user_id == last_user_id
      tagable.touch
    else
      tagable.update(last_user_id: last_user_id)
    end
  end
end
