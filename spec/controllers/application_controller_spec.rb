require 'rails_helper'

describe ApplicationController do
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
end
