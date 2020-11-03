# frozen_string_literal: true

class Person < ApplicationRecord
  include SingularTable
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

  def name_regex(require_first = true)
    titleize_names
    last_re = last_name_regex_str
    first = name_first

    if names = SHORT_FIRST_NAMES[first.downcase]
      first = [first].concat(Array(names).map(&:titleize)).join(' ')
    end

    fm = (require_first ? '' : first.to_s + ' ') + name_middle.to_s + ' ' + name_nick.to_s
    fm_ary = fm.split(/[[[:space:]]-]+/)
    initials = ''

    fm_ary.map! do |fm|
      length = fm.gsub(/[^\p{L}]/u, '').length
      fm.gsub!(/(\p{Ll})/u) { |m| "[#{m}#{m.upcase}]" }
      initials += fm[0].upcase
      if length > 3
        offset = fm.index(']', fm.index(']') + 1) + 1
        str = fm[offset..-1].gsub(']', ']?')
        fm = fm.slice(0, offset) + str
      end
      fm
    end

    fm = fm_ary.join('|')
    separator = '\b([\'"\(\)\.]{0,3}[[:space:]]+|\.[[:space:]]*|[[:space:]]?-[[:space:]]?)?'
    initials = initials.present? ? '[' + initials + ']' : ''

    if require_first
      nf_ary = first.split(/[[:space:]]+/mu)
      nf_ary.map! { |nf| nf.gsub(/(\p{Ll})/u) { |m| "[#{m}#{m.upcase}]" } }
      first = nf_ary.join('|')
      re = '((\b(' + first + ')' + separator + '(' + fm + '|' + initials + ')?' + separator + '((\p{L}|[\.\'\-])+' + separator + ')?)+((' + last_re + ')\b))'
    else
      re = '((\b(' + fm + '|' + initials + ')' + separator + '((\p{L}|[\.\'\-])+' + separator + ')?)+((' + last_re + ')\b))'
    end

    Regexp.new(re)
  end

  def last_name_regex_str
    name_last.gsub(/(\p{Ll})/u) { |m| "[#{m}#{m.upcase}]" }.gsub(/[[[:space:]]-]+/mu, '[[[:space:]]-]+')
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
