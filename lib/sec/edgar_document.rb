# frozen_string_literal: true

module Sec
  class EdgarDocument
    extend Forwardable
    attr_reader :url, :response

    def_delegators :@response, :success?
    def_delegator :@response, :body, :text

    def initialize(path)
      @url = "https://www.sec.gov/Archives/#{path}"
      @response = HTTParty.get(@url, headers: { 'User-Agent' => '' })
    end
  end
end
