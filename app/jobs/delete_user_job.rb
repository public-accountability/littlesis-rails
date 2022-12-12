# frozen_string_literal: true

class DeleteUserJob < ApplicationJob
  def perform(user_id)
    DeleteUserService.run(User.find(user_id))
  end

  def self.has_job_scheduled?(user_id)
    scheduled_job(user_id).length > 0
  end

  def self.scheduled_job(user_id)
    TypeCheck.check user_id, Integer
    ApplicationRecord.connection.exec_query(
      "SELECT * from good_jobs WHERE serialized_params->>'job_class' = 'DeleteUserJob' and (serialized_params->'arguments'->0)::integer = $1 ORDER BY created_at DESC LIMIT 1",
      "FindScheduledDeleteUserJobs",
      [user_id]
    )
  end
end
