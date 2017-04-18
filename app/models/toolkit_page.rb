class ToolkitPage < ActiveRecord::Base
  validates :name, uniqueness: true, presence: true
  before_validation :modify_name
  before_create :set_markdown_to_be_blank_string_if_nil
  belongs_to :last_user, foreign_key: "last_user_id", class_name: 'User'

  def self.pagify_name(name)
    name.downcase.tr(' ', '_')
  end

  private

  def set_markdown_to_be_blank_string_if_nil
    self.markdown = "" if markdown.nil?
  end

  def modify_name
    return if persisted? || name.nil?
    self.name = self.class.pagify_name(name)
  end
end
