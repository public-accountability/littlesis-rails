require 'rails_helper'

describe ApiUtils::Response do
  describe 'self.error' do
    RESPONSES = [:RECORD_NOT_FOUND, :RECORD_DELETED]
    it 'returns hash with errors and meta for all resposne types' do
      RESPONSES.each do |r|
        expect(ApiUtils::Response.error(r).fetch(:errors)).to be_a Array
        expect(ApiUtils::Response.error(r).fetch(:meta)).to be_a Hash
      end
    end
  end
end
