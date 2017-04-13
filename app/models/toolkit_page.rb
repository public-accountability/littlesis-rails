class ToolkitPage < ActiveRecord::Base
  validates :name, uniqueness: true, presence: true
  before_validation :modify_name
  belongs_to :last_user, foreign_key: "last_user_id", class_name: 'User'
  
  private

  def modify_name
    return if persisted? || name.nil?
    self.name = name.downcase.tr(' ', '_')
  end
end
