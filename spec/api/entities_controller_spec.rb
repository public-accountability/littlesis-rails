require 'rails_helper'

describe Api::EntitiesController, type: :controller do
  describe 'Private Methods' do
    describe 'page_requested' do
      let(:c) { Api::EntitiesController.new }

      it 'returns 1 if params page is missing' do
        allow(c).to receive(:params).and_return({})
        expect(c.send(:page_requested)).to eq 1
      end

      it 'returns int if valid int is provided' do
        allow(c).to receive(:params).and_return({:page => '7'})
        expect(c.send(:page_requested)).to eq 7
      end

      it 'defaults to 1 if invalid integer is provided' do
        allow(c).to receive(:params).and_return({:page => 'i would like page number three please'})
        expect(c.send(:page_requested)).to eq 1
      end
    end
  end
end
