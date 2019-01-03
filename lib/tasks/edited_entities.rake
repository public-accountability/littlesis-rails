# frozen_string_literal: true

namespace :edited_entities do
  desc 'populates table edited_entities using versions'
  task populate: :environment do
    EditedEntity.populate_table
  end
end
