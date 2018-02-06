class Tagging < ApplicationRecord
  GET_TAGABLE_ID_IF_ENTITY = proc { |t| t.tagable_id if t.tagable_class == 'Entity' }
  private_constant :GET_TAGABLE_ID_IF_ENTITY

  has_paper_trail meta: { entity1_id: GET_TAGABLE_ID_IF_ENTITY }

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
