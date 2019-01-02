# frozen_string_literal: true

# This adds custom methods to PaperTrail::Version
# see https://github.com/paper-trail-gem/paper_trail#6-extensibility
module PaperTrail
  class Version < ActiveRecord::Base
    include PaperTrail::VersionConcern

    # Determines this version referes to an entity
    def entity_edit?
      item_type == 'Entity' || entity1_id.present?
    end
  end
end
