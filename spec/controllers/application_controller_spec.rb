require 'rails_helper'

describe ApplicationController, type: :controller do
  class TestController < ApplicationController
    def current_user
      FactoryGirl.build(:user, sf_guard_user_id: 1000)
    end
  end

  describe 'blank_to_nil' do
    it 'converts blank strings to nil' do
      hash = { 'not_blank' => 'something', 'blank' => '' }
      expect(ApplicationController.new.send(:blank_to_nil, hash)).to eq({ 'not_blank' => 'something', 'blank' => nil })
    end

    it 'converts blank strings to nil for neseted hashes' do
      hash = { 'not_blank' => 'something', 'blank' => '', 'nested_attributes' => { 'somethingness' => 'yes', 'nothingness' => '' } }
      expect(ApplicationController.new.send(:blank_to_nil, hash))
        .to eq({ 'not_blank' => 'something', 'blank' => nil, 'nested_attributes' => { 'somethingness' => 'yes', 'nothingness' => nil } })
    end
  end

  describe 'prepare_update_params' do
    it 'returns hash with last_user_id and converted dates' do
      result = TestController.new.send(:prepare_update_params, { 'start_date' => '1999' })
      expect(result).to eq({ 'start_date' => '1999-00-00', 'last_user_id' => 1000 })
    end
  end
end
