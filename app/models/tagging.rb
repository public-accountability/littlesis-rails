class Tagging < ActiveRecord::Base
  belongs_to :tagable, polymorphic: true, foreign_type: :tagable_class
  belongs_to :last_user, class_name: "SfGuardUser", foreign_key: "last_user_id"
  validates_presence_of :tag_id, :tagable_class, :tagable_id

  belongs_to :tag

  after_save :update_tagable_timestamp

  def update_tagable_timestamp(last_user_id = APP_CONFIG['system_user_id'])
    if tagable.last_user_id == last_user_id
      tagable.touch
    else
      tagable.update(last_user_id: last_user_id)
    end
  end
end
