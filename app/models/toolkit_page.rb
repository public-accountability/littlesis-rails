class ToolkitPage < ActiveRecord::Base
  validates :name, uniqueness: true, presence: true
  
  belongs_to :last_user, foreign_key: "last_user_id", class_name: 'User'
  
end
