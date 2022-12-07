# frozen_string_literal: true

class DeleteUserJob < ApplicationJob
  def perform(user_id)
    DeleteUserService.run(User.find(user_id))
  end

  def self.has_job_scheduled?(user_id)
    TypeCheck.check user_id, Integer

    ApplicationRecord.connection.exec_query(
      "SELECT serialized_params->'arguments'->0 from good_jobs WHERE serialized_params->>'job_class' = 'DeleteUserJob' and (serialized_params->'arguments'->0)::integer = $1",
      "CheckScheduledDeleteUserJob",
      [user_id]
    ).first.present?
  end
end
