# frozen_string_literal: true

class CreateEditedEntityJob < ApplicationJob
  queue_as :default

  def perform(version)
    TypeCheck.check version, PaperTrail::Version
    EditedEntity.create_from_version(version)
  end
end
