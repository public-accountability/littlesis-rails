class ToolkitPage < ActiveRecord::Base
  validates :name, uniqueness: true, presence: true
  before_validation :modify_name
  belongs_to :last_user, foreign_key: "last_user_id", class_name: 'User'


  def self.pagify_name(name)
    name.downcase.tr(' ', '_')
  end
  
  private

  def modify_name
    return if persisted? || name.nil?
    self.name = self.class.pagify_name(name)
  end
end
