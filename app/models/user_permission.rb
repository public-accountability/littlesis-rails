class UserPermission < ActiveRecord::Base
  belongs_to :user
  validates_presence_of :user_id, :resource_type
end
