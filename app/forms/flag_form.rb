# frozen_string_literal: true

class FlagForm
  include ActiveModel::Model
  attr_accessor :email, :message, :page, :success

  validates :email, :page, :message, presence: true

  def create_flag
    if valid?
      UserFlag.create!(email: email, page: page, justification: message)
      self.success = true
    end
  end
end
