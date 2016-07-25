require 'rails_helper'

RSpec.describe OsDonation, type: :model do
  
  describe 'create_fec_cycle_id' do 
    it 'creates id' do 
      d = OsDonation.new
      d.cycle = '2010'
      d.fectransid = '123'
      expect(d.fec_cycle_id).to be_nil
      d.create_fec_cycle_id
      expect(d.fec_cycle_id).to eql('2010_123')
    end
  end
  
end
