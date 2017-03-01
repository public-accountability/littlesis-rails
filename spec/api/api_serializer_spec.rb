require 'rails_helper'

describe 'ApiSerializer' do
  it 'has MODEL_INFO const with common ignores' do
    expect(ApiUtils::Serializer::MODEL_INFO['common']).to be_a Hash
    expect(ApiUtils::Serializer::MODEL_INFO['common']['ignore']).to be_a Array
    expect(ApiUtils::Serializer::MODEL_INFO['common']['ignore']).to include 'last_user_id'
  end

  describe 'Entity' do
    let(:entity) { build(:corp, last_user_id: 123, id: rand(100)) }

    it 'removes last_user_id' do
      expect(ApiUtils::Serializer.new(entity).attributes.key?('last_user_id')).to be false
    end

    it 'removes id' do
      expect(ApiUtils::Serializer.new(entity).attributes.key?('id')).to be false
    end

    it 'keeps name' do
      expect(ApiUtils::Serializer.new(entity).attributes.key?('name')).to be true
    end
  end
end
