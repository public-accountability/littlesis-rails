# frozen_string_literal: true

NotableEntities = {
  :house_of_reps => 12_884,
  :senate => 12_885,
  :democratic_party => 12_886,
  :republican_party => 12_901
}.with_indifferent_access

NotableEntities.singleton_class.define_method(:get) do |entity|
  Entity.find fetch(entity)
end

NotableEntities.freeze
