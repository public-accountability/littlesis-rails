require 'rails_helper'

describe Api::EntitiesController, type: :controller do
  describe 'show' do
    context 'good request' do
      ATTRIBUTE_KEYS = %w(name blurb summary website parent_id primary_ext updated_at start_date end_date is_current link_count)
      before(:all)  { @pac = create(:pac) }
      before(:each) do
        get :show, id: @pac.id
        @json = JSON.parse(response.body)
      end

      it { should respond_with(200) }

      it 'is json' do
        expect(response.content_type).to eql 'application/json'
      end

      it 'has meta info' do
        ['copyright', 'license', 'apiVersion'].each do |k|
          expect(@json['meta'].key?(k)).to be true
        end
      end

      it 'sets type to be entities' do
        expect(@json['data']['type']).to eql 'entities'
      end

      it 'sets correct id' do
        expect(@json['data']['id']).to eql @pac.id
      end

      it 'has correct attribute keys' do
        ATTRIBUTE_KEYS.each { |k|expect(@json['data']['attributes'].key?(k)).to be true }
        expect(@json['data']['attributes']['name']).to eql 'PAC'
        expect(@json['data']['attributes']['primary_ext']).to eql 'Org'
      end

      it 'has url link' do
        expect(@json['data']['links'].key?('self')).to be true
      end
    end

    context 'record not found' do
      before { get :show, id: 100000000 }
      it { should respond_with(404) }
    end

    context 'record deleted' do
      before do
        @deleted_pac = create(:pac, is_deleted: true)
        get :show, id: @deleted_pac
      end
      it { should respond_with(410) }
    end
  end
end
