# frozen_string_literal: true

class SpamDetector
  CYRILLIC_RANGE = ("\u0400".ord.."\u04FF".ord).freeze
  CYRILLIC_MIN = 0.2

  # A spam bot is submitting fake bug reports using a random url in the page parameter
  def self.bug_report?(params)
    page = params['page']
    return false if page.downcase.include?('littlesis.org')

    Rails.logger.info "Spam bug report submitted by #{params['email']}"
    true
  end

  # We get a lot of spam in Russian
  def self.mostly_cyrillic?(string)
    return false if string.blank?

    string
      .split('')
      .filter { |char| %r{\W|[_:+/]}.match?(char) || CYRILLIC_RANGE.include?(char.ord) }
      .length
      .to_f
      .public_send(:/, string.length)
      .public_send(:>=, CYRILLIC_MIN)
  end
end
