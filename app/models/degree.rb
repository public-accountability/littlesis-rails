class Degree < ApplicationRecord
  def self.select_options
    all.map { |degree| [degree.name, degree.id] }
  end

  def self.select_options_cache
    Rails.cache.fetch('degree_select_options', expires_in: 1.day) { select_options }
  end
end
