# frozen_string_literal: true

NotableEntities = {
  :house_of_reps => 12_884,
  :senate => 12_885,
  :democratic_party => 12_886,
  :republican_party => 12_901,
  :trump => 15_108,
  :exxon => 2,
  :cuomo => 36_930,
  :deBlasio => 110_291
}.with_indifferent_access

NotableEntities.singleton_class.define_method(:get) do |entity|
  Entity.find fetch(entity)
end

NotableEntities.freeze
