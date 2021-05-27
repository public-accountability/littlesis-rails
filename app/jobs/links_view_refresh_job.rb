# frozen_string_literal: true

class LinksViewRefreshJob < ApplicationJob
  queue_as :default

  def perform
    Link.refresh_materialized_view
  end
end
