# frozen_string_literal: true

class CreateEditedEntityJob < ApplicationJob
  queue_as :default

  def perform(attributes)
    EditedEntity.create!(attributes)
  end
end
