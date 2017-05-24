require 'rails_helper'

describe ApiUtils::ApiResponseMeta do
  class TestResponse
    include ApiUtils::ApiResponseMeta
    def initialize(model)
      @model = model
    end
  end
  
  it 'has META hash constant' do
    expect(ApiUtils::ApiResponseMeta::META).to be_a Hash
    expect(ApiUtils::ApiResponseMeta::META).to have_key :copyright
    expect(ApiUtils::ApiResponseMeta::META).to have_key :license
    expect(ApiUtils::ApiResponseMeta::META).to have_key :apiVersion
  end

  describe 'meta' do
    it 'returns META if model is an entity' do
      expect(TestResponse.new(build(:org)).meta).to eq ApiUtils::ApiResponseMeta::META
    end

    it 'adds fields currentPage and pageCount if model is a ThinkingShinx::Search' do
      model = double('model')
      expect(model).to receive(:is_a?).with(ThinkingSphinx::Search).and_return(true)
      expect(model).to receive(:current_page).and_return(2)
      expect(model).to receive(:total_pages).and_return(4)
      meta = TestResponse.new(model).meta
      [:copyright, :license, :apiVersion, :currentPage, :pageCount].each do |k|
        expect(meta).to have_key k
      end
      expect(meta[:currentPage]).to eq 2
      expect(meta[:pageCount]).to eq 4
    end
  end
end
