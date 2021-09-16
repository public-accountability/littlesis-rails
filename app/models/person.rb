# frozen_string_literal: true

class Person < ApplicationRecord
  # Provides: SHORT_FIRST_NAMES, LONG_FIRST_NAMES, DISPLAY_ATTRIBUTES
  include PersonConstants

  serialize :nationality, Array

  has_paper_trail on: [:update, :destroy],
                  meta: { entity1_id: :entity_id }

  belongs_to :entity, inverse_of: :person, touch: true, optional: true
  validates :name_last, length: { maximum: 50 }, presence: true
  validates :name_first, length: { maximum: 50 }, presence: true

  # adds a new nationality it's not already in the array
  # str --> self
  def add_nationality(place)
    unless nationality.map(&:downcase).include?(place.downcase)
      nationality << place.titleize
    end
    self
  end

  def titleize_names
    %w(name_prefix name_first name_middle name_last name_suffix name_nick).each do |field|
      send(:"#{field}=", send(field).gsub(/^\p{Ll}/) { |m| m.upcase }) if send(field).present?
    end
  end

  def name_variations
    [
      [name_first, name_last],
      [name_first, name_middle, name_last],
      [name_first, name_nick, name_last],
      [name_nick, name_last],
      [name_prefix, name_first, name_middle, name_last],
      [name_prefix, name_first, name_middle, name_last, name_suffix]
    ].map { |arr| arr.delete_if(&:blank?) }
      .delete_if { |arr| arr.length < 2 }
      .uniq
      .map { |arr| arr.join(' ') }
  end

  def gender
    return 'Female' if gender_id == 1
    return 'Male' if gender_id == 2
    return 'Other' if gender_id == 3
  end

  def name_attributes
    attributes.slice("name_last", "name_first", "name_middle", "name_prefix", "name_suffix", "name_nick")
  end

  def first_middle_last
    [name_first, name_middle, name_last].filter(&:empty?).join(' ')
  end

  def last_first
    "#{name_last}, #{name_first}"
  end

  def self.same_first_names(name)
    Array.wrap(SHORT_FIRST_NAMES.fetch(name.downcase, []))
      .concat(Array.wrap(LONG_FIRST_NAMES.fetch(name.downcase, [])))
      .compact
  end

  def self.gender_to_id(gender)
    case gender.to_s.upcase
    when '1', 'FEMALE', 'F'
      1
    when '2', 'MALE', 'M'
      2
    when '3', 'OTHER', 'O', 'THEY', 'THEM'
      3
    end
  end
end
