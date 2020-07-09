# frozen_string_literal: true

class SpamDetector
  # A spam bot is submitting fake bug reports using a random url in the page parameter
  def self.bug_report?(params)
    page = params['page']
    return false if page.include?('littlesis.org')

    Rails.logger.info "Spam bug report submitted by #{params['email']}"
    true
  end
end
