# frozen_string_literal: true

class LinksViewRefreshJob < ApplicationJob
  queue_as :links_refreshes

  def perform
    # Avoid backing up lots of identical refreshes pointlessly
    return if Delayed::Job.where(queue: 'links_refreshes').count > 1

    @time_started = Time.current
    Link.refresh_materialized_view
  end

  # Touch entities with relationships that were updated while this job was running, so
  # that their caches automatically get refreshed with the new links data.
  def after_perform
    # rubocop:disable Rails/SkipsModelValidations
    Entity.with_relationships.where('entity.updated_at > ?', @time_started).touch_all
    # rubocop:enable Rails/SkipsModelValidations
  end
end
