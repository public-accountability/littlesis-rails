# frozen_string_literal: true

module Sec
  CIK_REGEX = /^[[:digit:]]{10}$/.freeze

  CIKS = {
    'GS' => '0000886982',
    'JPM' => '0000019617',
    'NFLX' => '0001065280'
  }.with_indifferent_access.freeze

  def self.verify_cik!(cik)
    raise InvalidCikNumber unless cik.present? && CIK_REGEX.match?(cik)
  end

  class InvalidCikNumber < StandardError; end
end
