# frozen_string_literal: true

class InternetArchiveJob < ApplicationJob
  def perform(url)
    if Rails.env.production?
      InternetArchive.save_url(url)
    end
  end
end
