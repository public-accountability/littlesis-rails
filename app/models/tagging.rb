class Tagging < ActiveRecord::Base
  validates_presence_of :tag_id, :tagable_class, :tagable_id
end
