require 'rails_helper'

describe EditsHelper, type: :helper do
  describe '#changeset_parse' do
    it 'removes updated_at and last_user_id' do
      h = { 'last_user_id' => 1, 'updated_at' => Time.now, 'another_field' => 'info' }
      expect(helper.changeset_parse(h)).to eq({ 'another_field' => 'info' })
    end
  end
end
