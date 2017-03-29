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

  describe 'Valid inputs' do
    it 'accepts active models' do
      expect { ApiUtils::Response.new(build(:org)) }.not_to raise_error
      expect { ApiUtils::Response.new(build(:extension_record)) }.not_to raise_error
    end

    it 'accepts arrays' do
      expect { ApiUtils::Response.new([build(:org)]) }.not_to raise_error
    end

    it 'does not accept other objects' do
      expect { ApiUtils::Response.new({}) }.to raise_error(ArgumentError)
    end
  end

  describe 'data_hash' do
    it 'entity data hash contains links' do
      expect(ApiUtils::Response.new(build(:org)).send(:data_hash)).to have_key :links
    end

    it 'ExtensionRecord data hash does not contains links' do
      expect(ApiUtils::Response.new(build(:extension_record))
              .send(:data_hash)).not_to have_key :links
    end
  end
end
