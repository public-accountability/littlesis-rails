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

    context 'extra fields with entity' do
      before(:all) do
        @corp = create(:corp, last_user_id: SfGuardUser.last.id)
        @corp.aliases.create!(name: 'other corp name')
        @corp.extension_records.create!(definition_id: 5)
      end

      it 'has aliases' do
        expect(ApiUtils::Serializer.new(@corp).attributes.key?('aliases')).to be true
        expect(ApiUtils::Serializer.new(@corp).attributes['aliases']).to include 'other corp name'
        expect(ApiUtils::Serializer.new(@corp).attributes['aliases'].length).to eql 2
      end

      it 'has types' do
        expect(ApiUtils::Serializer.new(@corp).attributes.key?('types')).to be true
        expect(ApiUtils::Serializer.new(@corp).attributes['types']).to include 'Business'
        expect(ApiUtils::Serializer.new(@corp).attributes['types'].length).to eql 2
      end
    end
  end

  describe 'ExtensionRecord' do
    let(:er) { build(:extension_record) }

    it 'serializes extension records' do
      expect(ApiUtils::Serializer.new(er).attributes)
        .to eql('definition_id' => 2, 'name' => 'Org', 'display_name' => 'Organization')
    end
  end
end
