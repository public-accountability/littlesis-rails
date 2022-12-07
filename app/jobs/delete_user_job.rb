# frozen_string_literal: true

class DeleteUserJob < ApplicationJob
  def perform(user_id)
    DeleteUserService.run(User.find(user_id))
  end
end
